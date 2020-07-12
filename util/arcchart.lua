
	local ArcChart = {}
	ArcChart.__index = ArcChart

	function ArcChart.create(config)
		
		--Variables local to this scope
		local requestedSegments
		
		local temp = {}
		setmetatable(temp, ArcChart)
		
		if (config.innerRadius) then
			temp.innerRadius = config.innerRadius
		else
			temp.innerRadius = 0
		end
		
		if (config.radius) then
			temp.outerRadius = config.radius
		end
		
		if (config.outerRadius) then
			temp.outerRadius = config.outerRadius
		end
		
		if (not temp.outerRadius) then
			return false
		end
		
		if (config.id) then
		
			temp.id = config.id
			
		end
		
		if (config.x and config.y) then
			temp.x = config.x
			temp.y = config.y
		else
			return false
		end
		
		if (config.segments) then
			requestedSegments = config.segments
		else
			requestedSegments = 60
		end
		
		if (config.drawmode) then
			if (config.drawmode == "fill") then
				temp.drawmode = "fill"
			end
			if (config.drawmode == "line") then
				temp.drawmode = "line" --Not recommended
			end
		end
		
		if (config.color) then
			temp.color = color
		end
		
		if (config.gradient) then
			temp.gradient = true
			temp.startcolor = config.startcolor
			temp.endcolor = config.endcolor
		end
		
		if (not temp.drawmode) then
			temp.drawmode = "fill"
		end
		
		if (config.precalculate and config.precalculate == false) then
			temp.precalculate = false
		else
			temp.precalculate = true
		end
		
		temp = ArcChart.setSegments(temp, requestedSegments)
		
		temp.startsegment = 0
		temp.endsegment = 0
		
		return temp
		
	end
	
	function ArcChart:increment(val)
	
		if (not val) then
			val = 1
		end
		
		if self.endsegment < self.totalSegments then		
			self.endsegment = self.endsegment + 1
			self.empty = false
		else
			self.full = true
		end
		
	end
	
	function ArcChart:reset(val)
	
		self.full = false
		
		if (not val or val == 0) then
			val = 0
			self.empty = true
		end
		
		self.endsegment = val
		
	end
	
	function ArcChart:decrement(val)
		
		if(not val) then
			val = 1
		end
		
		if self.endsegment == 0 then		
			self.empty = true
		else		
			self.endsegment = self.endsegment - val
		end
		
		self.full = false
	
	end
	

	function ArcChart:drawSegments(startseg, endseg)		
		if (self.totalSegments > endseg) then
			if (self.precalculated) then
				for currentSegment = startseg, endseg do
					love.graphics.polygon(
						self.drawmode,
						self.innerSegmentUpperX[currentSegment], self.innerSegmentUpperY[currentSegment],
						self.outerSegmentUpperX[currentSegment], self.outerSegmentUpperY[currentSegment],
						self.outerSegmentLowerX[currentSegment], self.outerSegmentLowerY[currentSegment],
						self.innerSegmentLowerX[currentSegment], self.innerSegmentLowerY[currentSegment]
					)
				end
			else
				self:__drawNotCalculated({
					segmentdraw = true,
					startSegment = startseg,
					endSegment = endSegment
				})
			end
		else
			return false
		end
	end

	function ArcChart:drawDegrees(startdegrees, enddegrees)
		
		if ((enddegrees - startdegrees) < 0) then
			return false
		end
		if (self.precalculated) then
			local degreesToDraw = enddegrees - startdegrees
			
			local segmentsToDraw = ((degreesToDraw - math.mod(degreesToDraw, self.degreesPerSegment))/self.degreesPerSegment)-1
			local startSegment = (startdegrees - math.mod(startdegrees, self.degreesPerSegment))/self.degreesPerSegment
			
			for currentSegment = startSegment, startSegment+segmentsToDraw do
				love.graphics.polygon(
					self.drawmode,
					self.innerSegmentUpperX[currentSegment], self.innerSegmentUpperY[currentSegment],
					self.outerSegmentUpperX[currentSegment], self.outerSegmentUpperY[currentSegment],
					self.outerSegmentLowerX[currentSegment], self.outerSegmentLowerY[currentSegment],
					self.innerSegmentLowerX[currentSegment], self.innerSegmentLowerY[currentSegment]
				)
			end
		else
			self:__drawNotCalculated({
				degreedraw = true,
				startDegrees = startdegrees,
				endDegrees = enddegrees				
			})
		end

	end

	function ArcChart:draw()
		if (self.precalculated) then
			if(self.endsegment > 0) then	
				for currentSegment = self.startsegment, self.endsegment do
					love.graphics.polygon(
						self.drawmode,
						self.innerSegmentUpperX[currentSegment], self.innerSegmentUpperY[currentSegment],
						self.outerSegmentUpperX[currentSegment], self.outerSegmentUpperY[currentSegment],
						self.outerSegmentLowerX[currentSegment], self.outerSegmentLowerY[currentSegment],
						self.innerSegmentLowerX[currentSegment], self.innerSegmentLowerY[currentSegment]
					)
				end
			end
		else
			self:__drawNotCalculated({
				segmentdraw = true,
				startSegment = self.startsegment,
				endSegment = self.endsegment
			})
		end
	end

	--Spendy operation to move chart, because it recalculates all of the position tables.

	function ArcChart:setPosition(x, y)

		self.x = x
		self.y = y
		
		if (self.precalculated) then
			ArcChart.setSegments(self, self.totalSegments)
		end
		
		return true, self
		
	end
	
	--When already intialized, pass oneself on to the static function
	function ArcChart:setSegments(requestedSegments)
		if self.precalculated then
			ArcChart.setSegments(self, requestedSegments)
		else
			self.totalSegments = requestedSegments
		end
	end
	
	--Static function that recalculates position table for all
	--Segments in the circle. Done(hopefully) only at initialization,
	--But can be called as needed if segment requirements change.
	function ArcChart.setSegments(temp, requestedSegments)

		temp.degreesPerSegment = (360 - math.mod(360,requestedSegments))/requestedSegments
		temp.totalSegments = 360 / (temp.degreesPerSegment - math.mod(360,temp.degreesPerSegment))
		
		--Precalculated coordinate tables so we don't have to do all this math just to draw the stupid arcs.
		
		temp.innerSegmentUpperX = {}
		temp.innerSegmentUpperY = {}
		temp.innerSegmentLowerX = {}
		temp.innerSegmentLowerY = {}
		
		temp.outerSegmentUpperX = {}
		temp.outerSegmentUpperY = {}
		temp.outerSegmentLowerX = {}
		temp.outerSegmentLowerY = {}
		
		--Define local variables
		local currentangle, nextangle
		local currentInnerAngleInRads, currentOuterAngleInRads
		local x1, x2, x3, x4
		local y1, y2, y3, y4
		
		for segment = 0, temp.totalSegments do
		
				currentangle = (segment) * temp.degreesPerSegment
				nextangle = (segment+1) * temp.degreesPerSegment
				
				currentOuterAngleInRads = math.rad(currentangle)
				currentInnerAngleInRads = math.rad(nextangle)
				
				x1 = temp.x+(temp.outerRadius*math.sin(currentOuterAngleInRads))
				y1 = temp.y-(temp.outerRadius*math.cos(currentOuterAngleInRads))
				
				x2 = temp.x+(temp.outerRadius*math.sin(currentInnerAngleInRads))
				y2 = temp.y-(temp.outerRadius*math.cos(currentInnerAngleInRads))
				
				x3 = temp.x+(temp.innerRadius*math.sin(currentOuterAngleInRads))
				y3 = temp.y-(temp.innerRadius*math.cos(currentOuterAngleInRads))
				
				x4 = temp.x+(temp.innerRadius*math.sin(currentInnerAngleInRads))
				y4 = temp.y-(temp.innerRadius*math.cos(currentInnerAngleInRads))
				
				temp.outerSegmentUpperX[segment], temp.outerSegmentUpperY[segment] = x1, y1
				temp.outerSegmentLowerX[segment], temp.outerSegmentLowerY[segment] = x2, y2
				temp.innerSegmentUpperX[segment], temp.innerSegmentUpperY[segment] = x3, y3
				temp.innerSegmentLowerX[segment], temp.innerSegmentLowerY[segment] = x4, y4
				
		end
		
		return temp
		
	end

	--Internal function for drawing if precalculated tables are not used
	--This function pretty much does the whole shebang in one go, and should not
	--be called directly.
	function ArcChart:__drawNotCalculated(args)
		
		--get integer number of degrees in a segment in whole(ish) circle.
		--warning: segments not dividing evenly into 360 degrees will result in unclosed arcs
		
		local startSegment, endSegment
		local totalSegments, degreesPerSegment
		
		if (args.segmentdraw) then
			startSegment = args.startSegment
			endSegment = args.endSegment
		end
		
		
		if (self.totalSegments) then
			requestedSegments = self.totalSegments
		end	
		
		degreesPerSegment = (360 - math.mod(360,requestedSegments))/requestedSegments
		totalSegments = 360 / (degreesPerSegment - math.mod(360,degreesPerSegment))
	
		if (args.degreedraw) then
			
			--get number of segments to draw
			degreesToDraw = (args.endDegrees-args.startDegrees)
			segmentsInArc = ((degreesToDraw - math.mod(degreesToDraw, degreesPerSegment))/degreesPerSegment)-1
			
			--get starting point segments
			correctedStartSegmentAngle = (args.startDegrees - (math.mod(args.startDegrees, degreesPerSegment)) / degreesPerSegment )
			startSegment = correctedStartSegmentAngle / degreesPerSegment
			endSegment = startSegment + segmentsInArc
			
		end
		
		local currentSegment
		local currentAngle
		local nextAngle
		
		for currentSegment = startSegment, endSegment do
		
			currentAngle = (currentSegment) * degreesPerSegment
			nextAngle = (currentSegment+1) * degreesPerSegment
			
			currentOuterAngleInRads = math.rad(currentAngle)
			currentInnerAngleInRads = math.rad(nextAngle)
			
			x1 = self.x+(self.outerRadius*math.sin(currentOuterAngleInRads))
			y1 = self.y-(self.outerRadius*math.cos(currentOuterAngleInRads))
			
			x2 = self.x+(self.outerRadius*math.sin(currentInnerAngleInRads))
			y2 = self.y-(self.outerRadius*math.cos(currentInnerAngleInRads))
			
			x3 = self.x+(self.innerRadius*math.sin(currentOuterAngleInRads))
			y3 = self.y-(self.innerRadius*math.cos(currentOuterAngleInRads))
			
			x4 = self.x+(self.innerRadius*math.sin(currentInnerAngleInRads))
			y4 = self.y-(self.innerRadius*math.cos(currentInnerAngleInRads))
			
			love.graphics.polygon("fill", x3,y3,x1,y1,x2,y2,x4,y4)
		
		end
		
	end

return ArcChart
