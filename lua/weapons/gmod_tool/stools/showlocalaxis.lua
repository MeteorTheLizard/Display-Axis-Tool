-- Provided by the UBox team. https://ubox.meteorthelizard.com

local sTag = "stool_display-axis"


TOOL.Category = "Information"
TOOL.Name = "#tool.showlocalaxis.name"

TOOL.ClientConVar["showxyz"] = "1"
TOOL.ClientConVar["showpyr"] = "1"
TOOL.ClientConVar["showdir"] = "1"

TOOL.Information = {
	{
		name = "left"
	},
	{
		name = "reload"
	}
}


if CLIENT then

	TOOL.tSelectedEntities = {}


	language.Add("Tool.showlocalaxis.name","Display Axis")
	language.Add("Tool.showlocalaxis.desc","Click on an entity to visualize axis components")
	language.Add("Tool.showlocalaxis.left","Primary: Add or remove object from display")
	language.Add("Tool.showlocalaxis.reload","Reload: Clear display")
	language.Add("Tool.showlocalaxis.warning","Please note:\n\nSome models have a weird center which is why they may have off-center lines. This is not the tools fault.")
	language.Add("Tool.showlocalaxis.toggle_one","Show X/Y/Z")
	language.Add("Tool.showlocalaxis.toggle_two","Show Rotation")
	language.Add("Tool.showlocalaxis.toggle_three","Show Direction")
	language.Add("Tool.showlocalaxis.credits","Provided by:\n\nThe UBox team.\nhttps://ubox.meteorthelizard.com")


	surface.CreateFont("showlocalaxisFont", {
		font = system.IsWindows() and "Verdana" or "Tahoma",
		size = 35
	})


	local fRenderText = function(vPos,sText,vColor,iTextScale)

		local aAngle = (vPos - EyePos()):Angle()
			aAngle:RotateAroundAxis(aAngle:Forward(),90)
			aAngle:RotateAroundAxis(aAngle:Right(),90)


		cam.Start3D2D(vPos,aAngle,iTextScale)
			cam.IgnoreZ(true)
			draw.DrawText(sText,"showlocalaxisFont",0,0,vColor,TEXT_ALIGN_CENTER)
		cam.End3D2D()

	end


	function TOOL:CreateDrawHook()

		-- Pre-caching

		local vector_zero = Vector(0,0,0)
		local angle_90r = Angle(0,0,90)
		local angle_90yr = Angle(0,90,90)

		local color_x = Color(200,0,0)
		local color_y = Color(0,200,0)
		local color_z = Color(0,0,200)

		local color_pitch = Color(0,200,200)
		local color_yaw = Color(200,200,0)
		local color_roll = Color(200,0,200)

		local color_white = Color(225,225,225)


		hook.Add("PostDrawTranslucentRenderables",sTag,function(_,bDrawingSkybox,isDraw3DSkybox)

			if bDrawingSkybox or isDraw3DSkybox then return end


			for eEntity in pairs(self.tSelectedEntities) do

				if not IsValid(eEntity) or eEntity == NULL then
					self.tSelectedEntities[eEntity] = nil

					goto nextEntity
				end


				self.bShowXYZ = self:GetClientNumber("showxyz",1)
				self.bShowPYR = self:GetClientNumber("showpyr",1)
				self.bShowDir = self:GetClientNumber("showdir",1)


				local vEntPos = eEntity:GetPos()
				local aEntAng = eEntity:GetAngles()


				local vOBBMaxs = eEntity:OBBMaxs()

				local iScale = math.max(vOBBMaxs.x,vOBBMaxs.y,vOBBMaxs.z)
					iScale = math.Clamp(iScale,10,1000)

				local iTextScale = math.Clamp(iScale / 200,0.1,1)


				-- Begin drawing

				if self.bShowXYZ == 1 then -- XYZ


					-- Lines

					cam.Start3D2D(vEntPos,aEntAng,1)
						cam.IgnoreZ(true)

						render.DrawLine(vector_zero,Vector(iScale,0,0)	,color_x)
						render.DrawLine(vector_zero,Vector(0,-iScale,0)	,color_y)
						render.DrawLine(vector_zero,Vector(0,0,iScale)	,color_z)
					cam.End3D2D()


					-- Text

					fRenderText(vEntPos + aEntAng:Forward() * iScale,"X+",color_x,iTextScale)
					fRenderText(vEntPos - aEntAng:Right()	* iScale,"Y+",color_y,iTextScale)
					fRenderText(vEntPos + aEntAng:Up()		* iScale,"Z+",color_z,iTextScale)

				end


				if self.bShowPYR == 1 then -- PYR

					local iPYRScale = (iScale / 50)


					-- Circles

					cam.Start3D2D(vEntPos,aEntAng + angle_90r,iPYRScale)
						surface.DrawCircle(0,0,32,0,200,200,255)
					cam.End3D2D()

					cam.Start3D2D(vEntPos,aEntAng,iPYRScale)
						surface.DrawCircle(0,0,32,200,200,0,255)
					cam.End3D2D()

					cam.Start3D2D(vEntPos,eEntity:LocalToWorldAngles(angle_90yr),iPYRScale)
						surface.DrawCircle(0,0,32,200,0,200,255)
					cam.End3D2D()


					-- Text

					fRenderText(vEntPos - aEntAng:Forward()	* iScale,"Pitch",color_pitch,iTextScale)
					fRenderText(vEntPos + aEntAng:Right()	* iScale,"Yaw"	,color_yaw	,iTextScale)
					fRenderText(vEntPos - aEntAng:Up()		* iScale,"Roll"	,color_roll	,iTextScale)

				end


				if self.bShowDir == 1 then -- Direction

					iScale = iScale * 1.5
					iTextScale = iTextScale * 0.75

					fRenderText(vEntPos + aEntAng:Forward()	* iScale,"Front",color_white,iTextScale)
					fRenderText(vEntPos - aEntAng:Forward()	* iScale,"Back"	,color_white,iTextScale)

					fRenderText(vEntPos + aEntAng:Right()	* iScale,"Right",color_white,iTextScale)
					fRenderText(vEntPos - aEntAng:Right()	* iScale,"Left"	,color_white,iTextScale)

					fRenderText(vEntPos + aEntAng:Up()		* iScale,"Up"	,color_white,iTextScale)
					fRenderText(vEntPos - aEntAng:Up()		* iScale,"Down"	,color_white,iTextScale)

				end


				::nextEntity::

			end
		end)
	end

end


function TOOL:LeftClick(tTrace)
	local eTarget = tTrace.Entity

	if IsValid(eTarget) and eTarget ~= game.GetWorld() then
		if CLIENT then

			if not self.tSelectedEntities[eTarget] then
				self.tSelectedEntities[eTarget] = true -- Add to list
			else
				self.tSelectedEntities[eTarget] = nil -- Remove from list
			end


			if table.Count(self.tSelectedEntities) > 0 then
				self:CreateDrawHook() -- Start drawing
			else
				self.tSelectedEntities = {}
				hook.Remove("PostDrawTranslucentRenderables",sTag) -- Reset all
			end
		end

		return true
	end

	return false
end


function TOOL:RightClick() -- No function
	return false
end


function TOOL:Reload() -- Reset all
	if CLIENT then
		self.tSelectedEntities = {}
		hook.Remove("PostDrawTranslucentRenderables",sTag)
	end

	return false
end


function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {
		Description = "#Tool.showlocalaxis.desc"
	})

	CPanel:AddControl("CheckBox", {
		Label = "#Tool.showlocalaxis.toggle_one",
		Command = "showlocalaxis_showxyz"
	})

	CPanel:AddControl("CheckBox", {
		Label = "#Tool.showlocalaxis.toggle_two",
		Command = "showlocalaxis_showpyr"
	})

	CPanel:AddControl("CheckBox", {
		Label = "#Tool.showlocalaxis.toggle_three",
		Command = "showlocalaxis_showdir"
	})

	CPanel:AddControl("Label", {
		Text = "#Tool.showlocalaxis.warning"
	})

	CPanel:AddControl("Label", {
		Text = "#Tool.showlocalaxis.credits"
	})
end