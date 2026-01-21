-- NYX EXOTIC - Interfaz Avanzada con Sistema de Secciones Modular
-- Tecla INSERT para abrir/cerrar, MouseButton2 para arrastrar

-- Servicios
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Sistema de Repositorio Modular
local NyxRepo = {
    Combat = {
        Aimbot = {
            Enabled = false,
            FOV = 70,
            Smoothness = 0.5,
            Keybind = "RightShift",
            TeamCheck = true,
            VisibleCheck = true
        },
        ESP = {
            Enabled = false,
            Color = Color3.fromRGB(255, 50, 50),
            ShowNames = true,
            ShowDistance = true,
            ShowBoxes = true,
            ShowHealth = true
        },
        Triggerbot = {
            Enabled = false,
            Delay = 0.1,
            Randomization = 0.05
        },
        SilentAim = {
            Enabled = false,
            HitChance = 100,
            HitPart = "Head"
        }
    },
    Visuals = {}, -- Ejemplo para otra sección
    Misc = {}     -- Ejemplo para otra sección
}

-- Interfaz principal
local NyxUI = {
    ScreenGui = nil,
    MainFrame = nil,
    TabsContainer = nil,
    ContentContainer = nil,
    CurrentTab = "Combat",
    IsOpen = false,
    Dragging = false,
    DragOffset = Vector2.new(0, 0),
    Tabs = {}
}

-- Paleta de colores avanzada
local Colors = {
    Background = Color3.fromRGB(15, 15, 20),
    Primary = Color3.fromRGB(140, 30, 200),
    PrimaryDark = Color3.fromRGB(110, 20, 170),
    Secondary = Color3.fromRGB(30, 30, 40),
    SecondaryDark = Color3.fromRGB(25, 25, 35),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(180, 180, 180),
    Success = Color3.fromRGB(50, 200, 100),
    Danger = Color3.fromRGB(220, 60, 60),
    Warning = Color3.fromRGB(220, 170, 50),
    Info = Color3.fromRGB(50, 150, 220),
    Border = Color3.fromRGB(60, 60, 80)
}

-- Configuración avanzada
local CONFIG = {
    WIDTH = 380,
    HEIGHT = 500,
    TAB_WIDTH = 80,
    ANIMATION_SPEED = 0.25,
    EASING_STYLE = Enum.EasingStyle.Quint,
    GLOW_INTENSITY = 0.15,
    BLUR_INTENSITY = 0.5
}

-- Sistema de componentes UI
local UIComponents = {}

function UIComponents:Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k == "Children" then
            for _, child in ipairs(v) do
                child.Parent = obj
            end
        elseif k == "Parent" then
            obj.Parent = v
        else
            obj[k] = v
        end
    end
    return obj
end

function UIComponents:ApplyGlow(frame)
    local glow = self:Create("ImageLabel", {
        Name = "Glow",
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://8992230678",
        ImageColor3 = Colors.Primary,
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(100, 100, 500, 500),
        ZIndex = 0
    })
    glow.Parent = frame
    return glow
end

function UIComponents:CreateSwitch(name, defaultValue, callback)
    local switch = {
        Value = defaultValue or false,
        Container = nil
    }
    
    switch.Container = self:Create("Frame", {
        Name = name .. "Switch",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Children = {
            self:Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(0.7, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Colors.Text,
                TextSize = 14,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            self:Create("Frame", {
                Name = "SwitchFrame",
                Size = UDim2.new(0, 50, 0, 24),
                Position = UDim2.new(1, -55, 0.5, -12),
                BackgroundColor3 = Colors.SecondaryDark,
                Children = {
                    self:Create("UICorner", {
                        CornerRadius = UDim.new(1, 0)
                    }),
                    self:Create("Frame", {
                        Name = "SwitchButton",
                        Size = UDim2.new(0, 20, 0, 20),
                        Position = UDim2.new(0, 2, 0.5, -10),
                        BackgroundColor3 = Colors.TextDark,
                        Children = {
                            self:Create("UICorner", {
                                CornerRadius = UDim.new(1, 0)
                            })
                        }
                    })
                }
            })
        }
    })
    
    local switchFrame = switch.Container:FindFirstChild("SwitchFrame")
    local switchButton = switchFrame:FindFirstChild("SwitchButton")
    
    local function updateSwitch()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if switch.Value then
            TweenService:Create(switchButton, tweenInfo, {
                Position = UDim2.new(1, -22, 0.5, -10),
                BackgroundColor3 = Colors.Success
            }):Play()
            TweenService:Create(switchFrame, tweenInfo, {
                BackgroundColor3 = Color3.new(0.2, 0.8, 0.3)
            }):Play()
        else
            TweenService:Create(switchButton, tweenInfo, {
                Position = UDim2.new(0, 2, 0.5, -10),
                BackgroundColor3 = Colors.TextDark
            }):Play()
            TweenService:Create(switchFrame, tweenInfo, {
                BackgroundColor3 = Colors.SecondaryDark
            }):Play()
        end
    end
    
    switchFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            switch.Value = not switch.Value
            updateSwitch()
            if callback then
                callback(switch.Value)
            end
        end
    end)
    
    updateSwitch()
    
    return switch
end

function UIComponents:CreateSlider(name, min, max, defaultValue, callback)
    local slider = {
        Value = defaultValue or min,
        Container = nil
    }
    
    slider.Container = self:Create("Frame", {
        Name = name .. "Slider",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        Children = {
            self:Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = name .. ": " .. defaultValue,
                TextColor3 = Colors.Text,
                TextSize = 14,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            self:Create("TextLabel", {
                Name = "ValueLabel",
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -40, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(defaultValue),
                TextColor3 = Colors.Primary,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right
            }),
            self:Create("Frame", {
                Name = "Track",
                Size = UDim2.new(1, 0, 0, 6),
                Position = UDim2.new(0, 0, 1, -20),
                BackgroundColor3 = Colors.SecondaryDark,
                Children = {
                    self:Create("UICorner", {
                        CornerRadius = UDim.new(1, 0)
                    }),
                    self:Create("Frame", {
                        Name = "Fill",
                        Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0),
                        BackgroundColor3 = Colors.Primary,
                        Children = {
                            self:Create("UICorner", {
                                CornerRadius = UDim.new(1, 0)
                            })
                        }
                    })
                }
            }),
            self:Create("Frame", {
                Name = "Thumb",
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new((defaultValue - min) / (max - min), -8, 1, -22),
                BackgroundColor3 = Colors.Text,
                Children = {
                    self:Create("UICorner", {
                        CornerRadius = UDim.new(1, 0)
                    }),
                    self:Create("UIStroke", {
                        Color = Colors.Primary,
                        Thickness = 2
                    })
                }
            })
        }
    })
    
    local track = slider.Container:FindFirstChild("Track")
    local fill = track:FindFirstChild("Fill")
    local thumb = slider.Container:FindFirstChild("Thumb")
    local valueLabel = slider.Container:FindFirstChild("ValueLabel")
    
    local function updateSlider(value)
        local percentage = (value - min) / (max - min)
        fill.Size = UDim2.new(percentage, 0, 1, 0)
        thumb.Position = UDim2.new(percentage, -8, 1, -22)
        valueLabel.Text = tostring(math.floor(value))
        slider.Container.Label.Text = name .. ": " .. math.floor(value)
        slider.Value = value
        if callback then
            callback(value)
        end
    end
    
    local function onInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local trackPos = track.AbsolutePosition
                local trackSize = track.AbsoluteSize
                
                local relativeX = math.clamp(mousePos.X - trackPos.X, 0, trackSize.X)
                local percentage = relativeX / trackSize.X
                local value = min + (max - min) * percentage
                
                updateSlider(value)
            end)
            
            UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                end
            end)
        end
    end
    
    track.InputBegan:Connect(onInput)
    thumb.InputBegan:Connect(onInput)
    
    return slider
end

function UIComponents:CreateDropdown(name, options, defaultIndex, callback)
    local dropdown = {
        Value = options[defaultIndex or 1],
        IsOpen = false,
        Container = nil
    }
    
    dropdown.Container = self:Create("Frame", {
        Name = name .. "Dropdown",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Children = {
            self:Create("TextButton", {
                Name = "MainButton",
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Colors.Secondary,
                Text = name .. ": " .. dropdown.Value,
                TextColor3 = Colors.Text,
                TextSize = 14,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Children = {
                    self:Create("UICorner", {
                        CornerRadius = UDim.new(0, 6)
                    }),
                    self:Create("ImageLabel", {
                        Name = "Arrow",
                        Size = UDim2.new(0, 16, 0, 16),
                        Position = UDim2.new(1, -25, 0.5, -8),
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://6031091004",
                        ImageColor3 = Colors.TextDark,
                        Rotation = 0
                    })
                }
            }),
            self:Create("Frame", {
                Name = "OptionsFrame",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 40),
                BackgroundColor3 = Colors.SecondaryDark,
                Children = {
                    self:Create("UICorner", {
                        CornerRadius = UDim.new(0, 6)
                    }),
                    self:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 2)
                    })
                }
            })
        }
    })
    
    local mainButton = dropdown.Container:FindFirstChild("MainButton")
    local arrow = mainButton:FindFirstChild("Arrow")
    local optionsFrame = dropdown.Container:FindFirstChild("OptionsFrame")
    local listLayout = optionsFrame:FindFirstChild("UIListLayout")
    
    -- Crear opciones
    for i, option in ipairs(options) do
        local optionButton = self:Create("TextButton", {
            Name = option,
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.new(0, 5, 0, (i-1)*32),
            BackgroundColor3 = Colors.SecondaryDark,
            Text = option,
            TextColor3 = Colors.TextDark,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            LayoutOrder = i,
            Children = {
                self:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4)
                })
            }
        })
        
        optionButton.MouseButton1Click:Connect(function()
            dropdown.Value = option
            mainButton.Text = name .. ": " .. option
            dropdown.IsOpen = false
            optionsFrame.Size = UDim2.new(1, 0, 0, 0)
            arrow.Rotation = 0
            if callback then
                callback(option)
            end
        end)
        
        optionButton.Parent = optionsFrame
    end
    
    mainButton.MouseButton1Click:Connect(function()
        dropdown.IsOpen = not dropdown.IsOpen
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        if dropdown.IsOpen then
            TweenService:Create(optionsFrame, tweenInfo, {
                Size = UDim2.new(1, 0, 0, #options * 32 + 5)
            }):Play()
            TweenService:Create(arrow, tweenInfo, {
                Rotation = 180
            }):Play()
        else
            TweenService:Create(optionsFrame, tweenInfo, {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            TweenService:Create(arrow, tweenInfo, {
                Rotation = 0
            }):Play()
        end
    end)
    
    return dropdown
end

function UIComponents:CreateColorPicker(name, defaultColor, callback)
    local colorPicker = {
        Value = defaultColor or Colors.Primary,
        Container = nil
    }
    
    colorPicker.Container = self:Create("Frame", {
        Name = name .. "ColorPicker",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Children = {
            self:Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(0.7, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Colors.Text,
                TextSize = 14,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            self:Create("TextButton", {
                Name = "ColorButton",
                Size = UDim2.new(0, 60, 0, 24),
                Position = UDim2.new(1, -65, 0.5, -12),
                BackgroundColor3 = defaultColor,
                Text = "",
                Children = {
                    self:Create("UICorner", {
                        CornerRadius = UDim.new(0, 4)
                    }),
                    self:Create("UIStroke", {
                        Color = Colors.Border,
                        Thickness = 1
                    })
                }
            })
        }
    })
    
    local colorButton = colorPicker.Container:FindFirstChild("ColorButton")
    
    local colors = {
        Color3.fromRGB(255, 50, 50),    -- Rojo
        Color3.fromRGB(50, 200, 100),   -- Verde
        Color3.fromRGB(50, 150, 220),   -- Azul
        Color3.fromRGB(220, 170, 50),   -- Amarillo
        Color3.fromRGB(180, 70, 220),   -- Púrpura
        Color3.fromRGB(255, 120, 50),   -- Naranja
        Color3.fromRGB(255, 255, 255)   -- Blanco
    }
    local colorIndex = 1
    
    for i, color in ipairs(colors) do
        if math.floor(color.R * 255) == math.floor(defaultColor.R * 255) and
           math.floor(color.G * 255) == math.floor(defaultColor.G * 255) and
           math.floor(color.B * 255) == math.floor(defaultColor.B * 255) then
            colorIndex = i
            break
        end
    end
    
    colorButton.MouseButton1Click:Connect(function()
        colorIndex = colorIndex + 1
        if colorIndex > #colors then
            colorIndex = 1
        end
        colorPicker.Value = colors[colorIndex]
        colorButton.BackgroundColor3 = colors[colorIndex]
        if callback then
            callback(colors[colorIndex])
        end
    end)
    
    return colorPicker
end

function UIComponents:CreateKeybindPicker(name, defaultKey, callback)
    local keybind = {
        Value = defaultKey or "RightShift",
        Listening = false,
        Container = nil
    }
    
    keybind.Container = self:Create("Frame", {
        Name = name .. "Keybind",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Children = {
            self:Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(0.7, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Colors.Text,
                TextSize = 14,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            self:Create("TextButton", {
                Name = "KeyButton",
                Size = UDim2.new(0, 80, 0, 24),
                Position = UDim2.new(1, -85, 0.5, -12),
                BackgroundColor3 = Colors.Secondary,
                Text = defaultKey,
                TextColor3 = Colors.Text,
                TextSize = 13,
                Font = Enum.Font.GothamSemibold,
                Children = {
                    self:Create("UICorner", {
                        CornerRadius = UDim.new(0, 4)
                    })
                }
            })
        }
    })
    
    local keyButton = keybind.Container:FindFirstChild("KeyButton")
    
    keyButton.MouseButton1Click:Connect(function()
        if not keybind.Listening then
            keybind.Listening = true
            keyButton.Text = "..."
            keyButton.BackgroundColor3 = Colors.Primary
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    local keyName = input.KeyCode.Name
                    keybind.Value = keyName
                    keyButton.Text = keyName
                    keyButton.BackgroundColor3 = Colors.Secondary
                    keybind.Listening = false
                    connection:Disconnect()
                    if callback then
                        callback(keyName)
                    end
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    keybind.Value = "MouseButton1"
                    keyButton.Text = "MB1"
                    keyButton.BackgroundColor3 = Colors.Secondary
                    keybind.Listening = false
                    connection:Disconnect()
                    if callback then
                        callback("MouseButton1")
                    end
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    keybind.Value = "MouseButton2"
                    keyButton.Text = "MB2"
                    keyButton.BackgroundColor3 = Colors.Secondary
                    keybind.Listening = false
                    connection:Disconnect()
                    if callback then
                        callback("MouseButton2")
                    end
                end
            end)
            
            task.wait(3)
            if keybind.Listening then
                keybind.Listening = false
                keyButton.Text = keybind.Value
                keyButton.BackgroundColor3 = Colors.Secondary
                if connection then
                    connection:Disconnect()
                end
            end
        end
    end)
    
    return keybind
end

-- Sistema de pestañas/secciones
function NyxUI:CreateTab(name, icon)
    local tab = {
        Name = name,
        Container = nil,
        Content = nil,
        Elements = {}
    }
    
    -- Botón de la pestaña
    tab.Container = UIComponents:Create("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(0, CONFIG.TAB_WIDTH, 0, 50),
        BackgroundColor3 = Colors.SecondaryDark,
        Text = "",
        Children = {
            UIComponents:Create("UICorner", {
                CornerRadius = UDim.new(0, 8)
            }),
            UIComponents:Create("TextLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(0.5, -12, 0.5, -12),
                BackgroundTransparency = 1,
                Text = icon or "⚔️",
                TextSize = 18,
                Font = Enum.Font.GothamBold,
                TextColor3 = Colors.TextDark
            }),
            UIComponents:Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 1, -20),
                BackgroundTransparency = 1,
                Text = name:upper(),
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                TextColor3 = Colors.TextDark,
                TextYAlignment = Enum.TextYAlignment.Top
            })
        }
    })
    
    -- Marco de contenido para esta pestaña
    tab.Content = UIComponents:Create("ScrollingFrame", {
        Name = name .. "Content",
        Size = UDim2.new(1, -20, 1, -100),
        Position = UDim2.new(0, 10, 0, 90),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Primary,
        Visible = false,
        Children = {
            UIComponents:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
        }
    })
    
    -- Eventos de la pestaña
    tab.Container.MouseButton1Click:Connect(function()
        self:SwitchTab(name)
    end)
    
    tab.Container.MouseEnter:Connect(function()
        if self.CurrentTab ~= name then
            game:GetService("TweenService"):Create(tab.Container, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.Secondary
            }):Play()
        end
    end)
    
    tab.Container.MouseLeave:Connect(function()
        if self.CurrentTab ~= name then
            game:GetService("TweenService"):Create(tab.Container, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.SecondaryDark
            }):Play()
        end
    end)
    
    self.Tabs[name] = tab
    return tab
end

-- Métodos para agregar elementos a pestañas
function NyxUI:AddSwitch(tabName, name, defaultValue, callback)
    local tab = self.Tabs[tabName]
    if not tab then return end
    
    local switch = UIComponents:CreateSwitch(name, defaultValue, callback)
    switch.Container.Parent = tab.Content
    switch.Container.LayoutOrder = #tab.Elements + 1
    table.insert(tab.Elements, switch)
    
    -- Actualizar tamaño del canvas
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, (#tab.Elements * 44) + 20)
    
    return switch
end

function NyxUI:AddSlider(tabName, name, min, max, defaultValue, callback)
    local tab = self.Tabs[tabName]
    if not tab then return end
    
    local slider = UIComponents:CreateSlider(name, min, max, defaultValue, callback)
    slider.Container.Parent = tab.Content
    slider.Container.LayoutOrder = #tab.Elements + 1
    table.insert(tab.Elements, slider)
    
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, (#tab.Elements * 44) + 20)
    
    return slider
end

function NyxUI:AddDropdown(tabName, name, options, defaultIndex, callback)
    local tab = self.Tabs[tabName]
    if not tab then return end
    
    local dropdown = UIComponents:CreateDropdown(name, options, defaultIndex, callback)
    dropdown.Container.Parent = tab.Content
    dropdown.Container.LayoutOrder = #tab.Elements + 1
    table.insert(tab.Elements, dropdown)
    
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, (#tab.Elements * 44) + 20)
    
    return dropdown
end

function NyxUI:AddColorPicker(tabName, name, defaultColor, callback)
    local tab = self.Tabs[tabName]
    if not tab then return end
    
    local colorPicker = UIComponents:CreateColorPicker(name, defaultColor, callback)
    colorPicker.Container.Parent = tab.Content
    colorPicker.Container.LayoutOrder = #tab.Elements + 1
    table.insert(tab.Elements, colorPicker)
    
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, (#tab.Elements * 44) + 20)
    
    return colorPicker
end

function NyxUI:AddKeybindPicker(tabName, name, defaultKey, callback)
    local tab = self.Tabs[tabName]
    if not tab then return end
    
    local keybind = UIComponents:CreateKeybindPicker(name, defaultKey, callback)
    keybind.Container.Parent = tab.Content
    keybind.Container.LayoutOrder = #tab.Elements + 1
    table.insert(tab.Elements, keybind)
    
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, (#tab.Elements * 44) + 20)
    
    return keybind
end

-- Cambiar pestaña
function NyxUI:SwitchTab(tabName)
    local tab = self.Tabs[tabName]
    if not tab then return end
    
    -- Ocultar pestaña actual
    if self.Tabs[self.CurrentTab] then
        self.Tabs[self.CurrentTab].Content.Visible = false
        local currentTabBtn = self.Tabs[self.CurrentTab].Container
        TweenService:Create(currentTabBtn, TweenInfo.new(0.3), {
            BackgroundColor3 = Colors.SecondaryDark
        }):Play()
        TweenService:Create(currentTabBtn.Icon, TweenInfo.new(0.3), {
            TextColor3 = Colors.TextDark
        }):Play()
        TweenService:Create(currentTabBtn.Label, TweenInfo.new(0.3), {
            TextColor3 = Colors.TextDark
        }):Play()
    end
    
    -- Mostrar nueva pestaña
    self.CurrentTab = tabName
    tab.Content.Visible = true
    
    local newTabBtn = tab.Container
    TweenService:Create(newTabBtn, TweenInfo.new(0.3), {
        BackgroundColor3 = Colors.Primary
    }):Play()
    TweenService:Create(newTabBtn.Icon, TweenInfo.new(0.3), {
        TextColor3 = Colors.Text
    }):Play()
    TweenService:Create(newTabBtn.Label, TweenInfo.new(0.3), {
        TextColor3 = Colors.Text
    }):Play()
end

-- Inicializar interfaz
function NyxUI:Init()
    -- Crear ScreenGui
    self.ScreenGui = UIComponents:Create("ScreenGui", {
        Name = "NyxExoticUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    
    -- Frame principal
    self.MainFrame = UIComponents:Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, CONFIG.WIDTH, 0, CONFIG.HEIGHT),
        Position = UDim2.new(1, 10, 0.5, -CONFIG.HEIGHT/2),
        BackgroundColor3 = Colors.Background,
        Children = {
            UIComponents:Create("UICorner", {
                CornerRadius = UDim.new(0, 12)
            }),
            UIComponents:Create("UIStroke", {
                Color = Colors.Border,
                Thickness = 1
            })
        }
    })
    
    -- Aplicar efecto glow
    UIComponents:ApplyGlow(self.MainFrame)
    
    -- Barra de título
    local titleBar = UIComponents:Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Colors.PrimaryDark,
        Children = {
            UIComponents:Create("UICorner", {
                CornerRadius = UDim.new(0, 12),
                Corner = {TopLeft = true, TopRight = true}
            }),
            UIComponents:Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = "NYX EXOTIC",
                TextColor3 = Colors.Text,
                TextSize = 18,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            UIComponents:Create("TextButton", {
                Name = "CloseBtn",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0.5, -10),
                BackgroundTransparency = 1,
                Text = "×",
                TextColor3 = Colors.Text,
                TextSize = 24,
                Font = Enum.Font.GothamBold
            })
        }
    })
    
    titleBar.Parent = self.MainFrame
    
    -- Contenedor de pestañas
    self.TabsContainer = UIComponents:Create("Frame", {
        Name = "TabsContainer",
        Size = UDim2.new(0, CONFIG.TAB_WIDTH + 20, 1, -50),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundTransparency = 1,
        Children = {
            UIComponents:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
        }
    })
    
    self.TabsContainer.Parent = self.MainFrame
    
    -- Contenedor de contenido
    self.ContentContainer = UIComponents:Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -CONFIG.TAB_WIDTH - 30, 1, -50),
        Position = UDim2.new(0, CONFIG.TAB_WIDTH + 20, 0, 50),
        BackgroundTransparency = 1
    })
    
    self.ContentContainer.Parent = self.MainFrame
    
    -- Crear pestañas por defecto
    self:CreateTab("Combat", "⚔️")
    self:CreateTab("Visuals", "👁️")
    self:CreateTab("Misc", "⚙️")
    
    -- Agregar pestañas al contenedor
    for _, tab in pairs(self.Tabs) do
        tab.Container.Parent = self.TabsContainer
        tab.Content.Parent = self.ContentContainer
    end
    
    -- Cargar contenido de Combat
    self:LoadCombatTab()
    
    -- Mostrar primera pestaña
    self:SwitchTab("Combat")
    
    -- Mostrar en pantalla
    self.ScreenGui.Parent = game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")
    
    -- Conectar eventos
    self:ConnectEvents()
    
    print("🎮 NYX EXOTIC | Interfaz cargada exitosamente")
    print("📌 Presiona INSERT para abrir/cerrar")
    print("📌 Click derecho en la barra de título para arrastrar")
end

-- Cargar contenido de Combat
function NyxUI:LoadCombatTab()
    -- AIMBOT SECTION
    self:AddSwitch("Combat", "Aimbot", false, function(state)
        NyxRepo.Combat.Aimbot.Enabled = state
        print("[Aimbot]", state and "ACTIVADO" or "DESACTIVADO")
    end)
    
    self:AddSlider("Combat", "Aimbot FOV", 1, 360, 70, function(value)
        NyxRepo.Combat.Aimbot.FOV = value
        print("[Aimbot FOV]", value)
    end)
    
    self:AddSlider("Combat", "Smoothness", 0.1, 1, 0.5, function(value)
        NyxRepo.Combat.Aimbot.Smoothness = value
        print("[Smoothness]", value)
    end)
    
    self:AddKeybindPicker("Combat", "Aimbot Key", "RightShift", function(key)
        NyxRepo.Combat.Aimbot.Keybind = key
        print("[Aimbot Key]", key)
    end)
    
    self:AddSwitch("Combat", "Team Check", true, function(state)
        NyxRepo.Combat.Aimbot.TeamCheck = state
        print("[Team Check]", state and "ON" or "OFF")
    end)
    
    self:AddSwitch("Combat", "Visible Check", true, function(state)
        NyxRepo.Combat.Aimbot.VisibleCheck = state
        print("[Visible Check]", state and "ON" or "OFF")
    end)
    
    -- ESP SECTION
    self:AddSwitch("Combat", "ESP", false, function(state)
        NyxRepo.Combat.ESP.Enabled = state
        print("[ESP]", state and "ACTIVADO" or "DESACTIVADO")
    end)
    
    self:AddColorPicker("Combat", "ESP Color", Color3.fromRGB(255, 50, 50), function(color)
        NyxRepo.Combat.ESP.Color = color
        print("[ESP Color]", color)
    end)
    
    self:AddSwitch("Combat", "Show Names", true, function(state)
        NyxRepo.Combat.ESP.ShowNames = state
        print("[Show Names]", state and "ON" or "OFF")
    end)
    
    self:AddSwitch("Combat", "Show Boxes", true, function(state)
        NyxRepo.Combat.ESP.ShowBoxes = state
        print("[Show Boxes]", state and "ON" or "OFF")
    end)
    
    self:AddSwitch("Combat", "Show Health", true, function(state)
        NyxRepo.Combat.ESP.ShowHealth = state
        print("[Show Health]", state and "ON" or "OFF")
    end)
    
    -- TRIGGERBOT SECTION
    self:AddSwitch("Combat", "Triggerbot", false, function(state)
        NyxRepo.Combat.Triggerbot.Enabled = state
        print("[Triggerbot]", state and "ACTIVADO" or "DESACTIVADO")
    end)
    
    self:AddSlider("Combat", "Trigger Delay", 0, 0.5, 0.1, function(value)
        NyxRepo.Combat.Triggerbot.Delay = value
        print("[Trigger Delay]", value)
    end)
    
    -- SILENT AIM SECTION
    self:AddSwitch("Combat", "Silent Aim", false, function(state)
        NyxRepo.Combat.SilentAim.Enabled = state
        print("[Silent Aim]", state and "ACTIVADO" or "DESACTIVADO")
    end)
    
    self:AddSlider("Combat", "Hit Chance", 0, 100, 100, function(value)
        NyxRepo.Combat.SilentAim.HitChance = value
        print("[Hit Chance]", value .. "%")
    end)
    
    self:AddDropdown("Combat", "Hit Part", {"Head", "Torso", "Random"}, 1, function(part)
        NyxRepo.Combat.SilentAim.HitPart = part
        print("[Hit Part]", part)
    end)
end

-- Conectar eventos
function NyxUI:ConnectEvents()
    -- Tecla INSERT para abrir/cerrar
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
            self:Toggle()
        end
    end)
    
    -- Botón cerrar
    self.MainFrame.TitleBar.CloseBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Arrastrar interfaz
    local titleBar = self.MainFrame:FindFirstChild("TitleBar")
    if titleBar then
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                self.Dragging = true
                self.DragOffset = Vector2.new(
                    Mouse.X - self.MainFrame.AbsolutePosition.X,
                    Mouse.Y - self.MainFrame.AbsolutePosition.Y
                )
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local newPos = UDim2.new(
                    0, Mouse.X - self.DragOffset.X,
                    0, Mouse.Y - self.DragOffset.Y
                )
                self.MainFrame.Position = newPos
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                self.Dragging = false
            end
        end)
    end
    
    -- Efectos hover en botones
    local function setupHoverEffects()
        for _, button in ipairs(self.MainFrame:GetDescendants()) do
            if button:IsA("TextButton") and button.Name ~= "CloseBtn" then
                button.MouseEnter:Connect(function()
                    if button.BackgroundColor3 ~= Colors.Primary then
                        game:GetService("TweenService"):Create(
                            button,
                            TweenInfo.new(0.2),
                            {BackgroundColor3 = Colors.Secondary}
                        ):Play()
                    end
                end)
                
                button.MouseLeave:Connect(function()
                    if button.BackgroundColor3 == Colors.Secondary then
                        game:GetService("TweenService"):Create(
                            button,
                            TweenInfo.new(0.2),
                            {BackgroundColor3 = Colors.SecondaryDark}
                        ):Play()
                    end
                end)
            end
        end
    end
    
    setupHoverEffects()
end

-- Alternar visibilidad
function NyxUI:Toggle()
    self.IsOpen = not self.IsOpen
    
    local tweenInfo = TweenInfo.new(
        CONFIG.ANIMATION_SPEED,
        CONFIG.EASING_STYLE,
        Enum.EasingDirection.Out
    )
    
    local targetPosition
    if self.IsOpen then
        targetPosition = UDim2.new(1, -CONFIG.WIDTH - 10, 0.5, -CONFIG.HEIGHT/2)
    else
        targetPosition = UDim2.new(1, 10, 0.5, -CONFIG.HEIGHT/2)
    end
    
    local tween = TweenService:Create(
        self.MainFrame,
        tweenInfo,
        {Position = targetPosition}
    )
    tween:Play()
    
    print("[NYX EXOTIC]", self.IsOpen and "INTERFAZ ABIERTA" or "INTERFAZ CERRADA")
end

-- ===========================================
-- FUNCIONES PÚBLICAS PARA AGREGAR NUEVAS SECCIONES
-- ===========================================

function AddSection(sectionName, icon)
    if NyxUI.Tabs[sectionName] then
        warn("⚠️ La sección '" .. sectionName .. "' ya existe")
        return NyxUI.Tabs[sectionName]
    end
    
    print("➕ Creando nueva sección:", sectionName)
    
    -- Crear en repositorio
    if not NyxRepo[sectionName] then
        NyxRepo[sectionName] = {}
    end
    
    -- Crear pestaña UI
    local newTab = NyxUI:CreateTab(sectionName, icon or "✨")
    
    return newTab
end

-- ===========================================
-- EJEMPLOS DE USO (COMENTADOS)
-- ===========================================

--[[
-- Para agregar una nueva sección:
local VisualsTab = AddSection("Visuals", "👁️")

-- Para agregar elementos a esa sección:
NyxUI:AddSwitch("Visuals", "Wallhack", false, function(state)
    print("[Wallhack]", state)
end)

NyxUI:AddSlider("Visuals", "Brightness", 0, 100, 50, function(value)
    print("[Brightness]", value)
end)

NyxUI:AddColorPicker("Visuals", "Chams Color", Color3.fromRGB(0, 255, 255), function(color)
    print("[Chams Color]", color)
end)
--]]

-- ===========================================
-- INICIALIZACIÓN
-- ===========================================

-- Iniciar interfaz
NyxUI:Init()

-- Devolver API pública
local NYX_API = {
    UI = NyxUI,
    Repo = NyxRepo,
    AddSection = AddSection,
    AddSwitch = function(section, name, default, callback)
        return NyxUI:AddSwitch(section, name, default, callback)
    end,
    AddSlider = function(section, name, min, max, default, callback)
        return NyxUI:AddSlider(section, name, min, max, default, callback)
    end,
    AddDropdown = function(section, name, options, default, callback)
        return NyxUI:AddDropdown(section, name, options, default, callback)
    end,
    AddColorPicker = function(section, name, color, callback)
        return NyxUI:AddColorPicker(section, name, color, callback)
    end,
    AddKeybind = function(section, name, key, callback)
        return NyxUI:AddKeybindPicker(section, name, key, callback)
    end
}

return NYX_API
