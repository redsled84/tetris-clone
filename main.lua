local grid = {
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
}

local tileSize = 23

local pieces = {
	{
		{1, 1},
		{1, 1}
	},
	{
		{1, 1, 1, 1}
	},
	{
		{0, 1, 1},
		{1, 1, 0}
	},
	{
		{1, 1, 0},
		{0, 1, 1}
	},
	{
		{1, 0},
		{1, 0},
		{1, 1}
	},
	{
		{0, 1},
		{0, 1},
		{1, 1}
	},
	{
		{1, 1, 1},
		{0, 1, 0}
	}
}

local maxPieceTimer = .05
local pieceTimer = 0
local activePiece

function updatePieceTimer(dt, f)
	if pieceTimer > 0 then
		pieceTimer = pieceTimer - dt
	else
		f()
		pieceTimer = maxPieceTimer
	end
end

function getGridDimensions()
	return #grid, #grid[1]
end

function getActivePieceDimensions()
	return #activePiece.data[1], #activePiece.data
end

function drawGrid()
	local height, width = getGridDimensions()

	for y = 1, height do
		for x = 1, width do
			local n = grid[y][x]

			if n == 0 then
				love.graphics.setColor(255, 255, 255, 100)
				love.graphics.rectangle("line", x * tileSize, y * tileSize,
					tileSize, tileSize)
			elseif n == 1 then
				love.graphics.setColor(255, 0, 255, 100)
				love.graphics.rectangle("fill", x * tileSize, y * tileSize,
					tileSize, tileSize)
			end
		end
	end
end

function moveActivePieceX(n)
	if activePiece then
		-- ensure that the piece doesn't go out of the grid
		if (n > 0 and activePiece.x + #activePiece.data[1] + n <= #grid[1])
		or (n < 0 and activePiece.x + n >= 0) then
			activePiece.x = activePiece.x + n
		end
	end
end

function moveActivePieceY()
	if activePiece then
		activePiece.y = activePiece.y + 1
	end
end

function drawActivePiece()
	local width, height = getActivePieceDimensions()

	love.graphics.setColor(0, 255, 0)
	for y = 1, height do
		for x = 1, width do
			local n = activePiece.data[y][x]
			if n == 1 then
				love.graphics.rectangle("line",
					x * tileSize + activePiece.x * tileSize,
					y * tileSize + activePiece.y * tileSize,
					tileSize, tileSize)
			end
		end
	end
end

function getRandomPiece()
	local pieceN = love.math.random(1, #pieces)

	return {
		data = pieces[pieceN],
		x = love.math.random(0, #grid[1] - #pieces[pieceN][1]),
		y = 0,
		rot = 0,
	}
end

function addActivePieceToGrid()
	local height, width = getGridDimensions()
	local activeWidth, activeHeight = getActivePieceDimensions()

	-- add piece to grid if gets to bottom
	if activePiece.y + activeHeight >= height then
		return true
	end

	-- add piece if it is going to intersect with grid values
	for y = 1, height do
		for x = 1, width do
			local n = grid[y][x]

			if n == 1 and y - (activePiece.y + activeHeight) == 1
			and x >= activePiece.x and x <= activePiece.x + activeWidth then
				for i = 1, activeWidth do
					for j = 1, activeHeight do
						local z = activePiece.data[j][i]

						if z == 1 then
							return true 
						end
					end
				end
			end
		end
	end

	return false
end

function updateGridAndActivePiece()
	if addActivePieceToGrid() then
		local activeWidth, activeHeight = getActivePieceDimensions()
		for y = 1, activeHeight do
			for x = 1, activeWidth do
				local n = activePiece.data[y][x]
				if n == 1 then
					grid[y + activePiece.y][x + activePiece.x] = 1
				end
			end
		end


		activePiece = getRandomPiece()
	end
end

function love.load()
	activePiece = getRandomPiece()
end

function love.update(dt)
	updateGridAndActivePiece()

	updatePieceTimer(dt, moveActivePieceY)
end

function love.draw()
	drawGrid()
	drawActivePiece()
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
	if key == "right" then
		moveActivePieceX(1)
	elseif key == "left" then
		moveActivePieceX(-1)
	end
end