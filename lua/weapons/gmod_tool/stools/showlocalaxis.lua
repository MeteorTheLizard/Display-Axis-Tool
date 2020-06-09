TOOL.Category = "Construction"
TOOL.Name = "#tool.showlocalaxis.name"
TOOL.ClientConVar["showxyz"] = "1"
TOOL.ClientConVar["showpyr"] = "1"
TOOL.ClientConVar["showdir"] = "1"
local VisualizedEnts = {}
local IntX, IntY, IntZ

if CLIENT then
    language.Add("Tool.showlocalaxis.name", "Display Axis")
    language.Add("Tool.showlocalaxis.desc", "Click on an entity to visualize certain axis components")
    language.Add("Tool.showlocalaxis.left", "Primary: Add object to display")
    language.Add("Tool.showlocalaxis.right", "Secondary: Remove object from display")
    language.Add("Tool.showlocalaxis.reload", "Reload: Clear display")
    language.Add("Tool.showlocalaxis.warning", "Please note: The majority of props have a weird center which is why some props may have off-center lines. This is not the tools fault.")

    local me
    hook.Add("InitPostEntity","displayaxis_meinit",function()
        hook.Remove("InitPostEntity","displayaxis_meinit")
        me = LocalPlayer()
    end)

    surface.CreateFont("showlocalaxisFont", {
        font = system.IsWindows() and "Verdana" or "Tahoma",
        size = 75,
        weight = 600
    })

    local vector_zero = Vector(0, 0, 0)

    TOOL.CreateDrawHook = function()
        hook.Add("PostDrawTranslucentRenderables", "TOOL_showlocalaxis_Draw", function()
            for k, v in pairs(VisualizedEnts) do
                if not IsValid(v) or v == NULL then
                    VisualizedEnts[k] = nil
                else
                    local DrawXYZ = (IntX or 1)
                    local DrawPYR = (IntY or 1)
                    local DrawDIR = (IntZ or 1)
                    local EntPos = v:GetPos()
                    local EntAng = v:GetAngles()
                    local MyPos = me:GetPos()
                    local EyePos = me:EyePos()
                    local AxisScaleX = v:OBBMaxs().X
                    local AxisScaleY = v:OBBMaxs().Y
                    local AxisScaleZ = v:OBBMaxs().Z
                    local AxisScale = ((AxisScaleX > AxisScaleY and AxisScaleX > AxisScaleZ and AxisScaleX) or (AxisScaleY > AxisScaleX and AxisScaleY > AxisScaleZ and AxisScaleY) or (AxisScaleZ > AxisScaleX and AxisScaleZ > AxisScaleY and AxisScaleZ) or AxisScaleY)
                    AxisScale = math.Clamp(AxisScale, 10, 1000)

                    if DrawXYZ == 1 then
                        cam.Start3D2D(EntPos, EntAng, 1)
							cam.IgnoreZ(true)
							render.DrawLine(vector_zero, Vector(AxisScale, 0, 0), Color(0, 0, 200))
							render.DrawLine(vector_zero, Vector(0, -AxisScale, 0), Color(0, 200, 0))
							render.DrawLine(vector_zero, Vector(0, 0, AxisScale), Color(200, 0, 0))
                        cam.End3D2D()
                        local XPos = (EntPos + EntAng:Forward() * AxisScale)
                        local YPos = (EntPos - EntAng:Right() * AxisScale)
                        local ZPos = (EntPos + EntAng:Up() * AxisScale)
                        local TextPositions = {
							XPos, 
							math.atan2(MyPos.y - (EntPos + EntAng:Forward() * AxisScale).y, MyPos.x - (EntPos + EntAng:Forward() * AxisScale).x) * 57.2958, 
							math.atan2(XPos.z - EyePos.z + Vector(25, 0, 0).z, math.sqrt((XPos.x - MyPos.x) * (XPos.x - MyPos.x) + (XPos.y - MyPos.y) * (XPos.y - MyPos.y))) * 57.2958, 

							YPos, 
							math.atan2(MyPos.y - (EntPos - EntAng:Right() * AxisScale).y, MyPos.x - (EntPos - EntAng:Right() * AxisScale).x) * 57.2958, 
							math.atan2(YPos.z - EyePos.z + Vector(25, 0, 0).z, math.sqrt((YPos.x - MyPos.x) * (YPos.x - MyPos.x) + (YPos.y - MyPos.y) * (YPos.y - MyPos.y))) * 57.2958, 

							ZPos, 
							math.atan2(MyPos.y - (EntPos + EntAng:Up() * AxisScale).y, MyPos.x - (EntPos + EntAng:Up() * AxisScale).x) * 57.2958, 
							math.atan2(ZPos.z - EyePos.z + Vector(25, 0, 0).z, math.sqrt((ZPos.x - MyPos.x) * (ZPos.x - MyPos.x) + (ZPos.y - MyPos.y) * (ZPos.y - MyPos.y))) * 57.2958
						}

                        for k = 1, 9 do
                            if k ~= 1 and k ~= 4 and k ~= 7 then continue end
                            cam.Start3D2D(TextPositions[k], Angle(0, TextPositions[k + 1] + 90, TextPositions[k + 2] + 90), 0.1 * (AxisScale / 35))
								cam.IgnoreZ(true)
								draw.DrawText(k == 1 and "X+" or k == 4 and "Y+" or k == 7 and "Z+", "showlocalaxisFont", 0, 0, k == 1 and Color(0, 0, 200) or k == 4 and Color(0, 200, 0) or k == 7 and Color(200, 0, 0), TEXT_ALIGN_LEFT)
                            cam.End3D2D()
                        end
                    end

                    if DrawPYR == 1 then
                        local Scale = AxisScale / 100
						cam.Start3D2D(EntPos, EntAng + Angle(0, 0, 90), Scale)
							surface.DrawCircle(0, 0, 64, 200, 200, 0, 255)
                        cam.End3D2D()
						cam.Start3D2D(EntPos, EntAng, Scale)
							surface.DrawCircle(0, 0, 64, 0, 200, 200, 255)
                        cam.End3D2D()
						cam.Start3D2D(EntPos, v:LocalToWorldAngles(Angle(0, 90, 90)), Scale)
							surface.DrawCircle(0, 0, 64, 200, 0, 200, 255)
                        cam.End3D2D()
                        local XPos = (EntPos - EntAng:Forward() * AxisScale)
                        local YPos = (EntPos + EntAng:Right() * AxisScale)
                        local ZPos = (EntPos - EntAng:Up() * AxisScale)
                        local TextPositions = {
							XPos, 
							math.atan2(MyPos.y - (EntPos - EntAng:Forward() * AxisScale).y, MyPos.x - (EntPos - EntAng:Forward() * AxisScale).x) * 57.2958, 
							math.atan2(XPos.z - EyePos.z + Vector(25, 0, 0).z, math.sqrt((XPos.x - MyPos.x) * (XPos.x - MyPos.x) + (XPos.y - MyPos.y) * (XPos.y - MyPos.y))) * 57.2958, 

							YPos, 
							math.atan2(MyPos.y - (EntPos + EntAng:Right() * AxisScale).y, MyPos.x - (EntPos + EntAng:Right() * AxisScale).x) * 57.2958, 
							math.atan2(YPos.z - EyePos.z + Vector(25, 0, 0).z, math.sqrt((YPos.x - MyPos.x) * (YPos.x - MyPos.x) + (YPos.y - MyPos.y) * (YPos.y - MyPos.y))) * 57.2958, 

							ZPos, 
							math.atan2(MyPos.y - (EntPos - EntAng:Up() * AxisScale).y, MyPos.x - (EntPos - EntAng:Up() * AxisScale).x) * 57.2958, 
							math.atan2(ZPos.z - EyePos.z + Vector(25, 0, 0).z, math.sqrt((ZPos.x - MyPos.x) * (ZPos.x - MyPos.x) + (ZPos.y - MyPos.y) * (ZPos.y - MyPos.y))) * 57.2958
						}

                        for k = 1, 9 do
                            if k ~= 1 and k ~= 4 and k ~= 7 then continue end
                            cam.Start3D2D(TextPositions[k], Angle(0, TextPositions[k + 1] + 90, TextPositions[k + 2] + 90), 0.1 * (AxisScale / 65))
								cam.IgnoreZ(true)
								draw.DrawText(k == 1 and "Pitch" or k == 4 and "Yaw" or k == 7 and "Roll", "showlocalaxisFont", 0, 0, k == 1 and Color(200, 200, 0) or k == 4 and Color(0, 200, 200) or k == 7 and Color(200, 0, 200), TEXT_ALIGN_CENTER)
                            cam.End3D2D()
                        end
                    end

                    if DrawDIR == 1 then
                        AxisScale = AxisScale * 1.5
                        local Directions = {EntPos + EntAng:Forward() * AxisScale, EntPos - EntAng:Forward() * AxisScale, EntPos + EntAng:Up() * AxisScale, EntPos - EntAng:Up() * AxisScale, EntPos + EntAng:Right() * AxisScale, EntPos - EntAng:Right() * AxisScale}
                        local TextPositions = {
							Directions[1], 
							math.atan2(MyPos.y - (EntPos + EntAng:Forward() * AxisScale).y, MyPos.x - (EntPos + EntAng:Forward() * AxisScale).x) * 57.2958,
							math.atan2(Directions[1].z - EyePos.z + Vector(25, 0, 0).z, math.sqrt((Directions[1].x - MyPos.x) * (Directions[1].x - MyPos.x) + (Directions[1].y - MyPos.y) * (Directions[1].y - MyPos.y))) * 57.2958, 

							Directions[2], 
							math.atan2(MyPos.y - (EntPos - EntAng:Forward() * AxisScale).y, MyPos.x - (EntPos - EntAng:Forward() * AxisScale).x) * 57.2958, 
							math.atan2(Directions[2].z - EyePos.z + Vector(25, 0, 0).z, math.sqrt((Directions[2].x - MyPos.x) * (Directions[2].x - MyPos.x) + (Directions[2].y - MyPos.y) * (Directions[2].y - MyPos.y))) * 57.2958, 

							Directions[3], 
							math.atan2(MyPos.y - (EntPos - EntAng:Up() * AxisScale).y, MyPos.x - (EntPos - EntAng:Up() * AxisScale).x) * 57.2958, 
							math.atan2(Directions[3].z - EyePos.z + Vector(25, 0, 0).z, math.sqrt((Directions[3].x - MyPos.x) * (Directions[3].x - MyPos.x) + (Directions[3].y - MyPos.y) * (Directions[3].y - MyPos.y))) * 57.2958, 

							Directions[4], 
							math.atan2(MyPos.y - (EntPos - EntAng:Up() * AxisScale).y, MyPos.x - (EntPos - EntAng:Up() * AxisScale).x) * 57.2958, 
							math.atan2(Directions[4].z - EyePos.z + Vector(25, 0, 0).z, math.sqrt((Directions[4].x - MyPos.x) * (Directions[4].x - MyPos.x) + (Directions[4].y - MyPos.y) * (Directions[4].y - MyPos.y))) * 57.2958, 

							Directions[5], 
							math.atan2(MyPos.y - (EntPos + EntAng:Right() * AxisScale).y, MyPos.x - (EntPos + EntAng:Right() * AxisScale).x) * 57.2958, 
							math.atan2(Directions[5].z - EyePos.z + Vector(25, 0, 0).z, math.sqrt((Directions[5].x - MyPos.x) * (Directions[5].x - MyPos.x) + (Directions[5].y - MyPos.y) * (Directions[5].y - MyPos.y))) * 57.2958, 

							Directions[6], 
							math.atan2(MyPos.y - (EntPos - EntAng:Right() * AxisScale).y, MyPos.x - (EntPos - EntAng:Right() * AxisScale).x) * 57.2958, 
							math.atan2(Directions[6].z - EyePos.z + Vector(25, 0, 0).z, math.sqrt((Directions[6].x - MyPos.x) * (Directions[6].x - MyPos.x) + (Directions[6].y - MyPos.y) * (Directions[6].y - MyPos.y))) * 57.2958
						}

                        for k = 1, 18 do
                            if k ~= 1 and k ~= 4 and k ~= 7 and k ~= 10 and k ~= 13 and k ~= 16 then continue end
                            cam.Start3D2D(TextPositions[k], Angle(0, TextPositions[k + 1] + 90, TextPositions[k + 2] + 90), 0.1 * (AxisScale / 75))
								cam.IgnoreZ(true)
								draw.DrawText(k == 1 and "Front" or k == 4 and "Back" or k == 7 and "Up" or k == 10 and "Down" or k == 13 and "Right" or k == 16 and "Left", "showlocalaxisFont", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER)
                            cam.End3D2D()
                        end
                    end
                end
            end
        end)
    end
end

TOOL.Information = {
    {
        name = "left"
    },
    {
        name = "right"
    },
    {
        name = "reload"
    }
}

function TOOL:LeftClick(trace)
    local Ent = trace.Entity

    if IsValid(Ent) and Ent ~= Entity(0) then
        if CLIENT then
            IntX = self:GetClientNumber("showxyz", 1)
            IntY = self:GetClientNumber("showpyr", 1)
            IntZ = self:GetClientNumber("showdir", 1)
            VisualizedEnts[Ent:EntIndex()] = Ent
            self:CreateDrawHook()
        end

        return true
    end

    return false
end

function TOOL:RightClick(trace)
    local Ent = trace.Entity

    if IsValid(Ent) and Ent ~= Entity(0) then
        if CLIENT then
            VisualizedEnts[Ent:EntIndex()] = nil
            self:CreateDrawHook()
        end

        return true
    end

    return false
end

function TOOL:Reload()
    if CLIENT then
        VisualizedEnts = {}
        hook.Remove("PostDrawTranslucentRenderables", "TOOL_showlocalaxis_Draw")
    end

    return true
end

function TOOL.BuildCPanel(CPanel)
    CPanel:AddControl("Header", {
        Description = "#Tool.showlocalaxis.desc"
    })

    CPanel:AddControl("CheckBox", {
        Label = "Show X/Y/Z Axis",
        Command = "showlocalaxis_showxyz"
    })

    CPanel:AddControl("CheckBox", {
        Label = "Show Rotation Axis",
        Command = "showlocalaxis_showpyr"
    })

    CPanel:AddControl("CheckBox", {
        Label = "Show Directions",
        Command = "showlocalaxis_showdir"
    })

    CPanel:AddControl("Label", {
        Text = "#Tool.showlocalaxis.warning"
    })
end
