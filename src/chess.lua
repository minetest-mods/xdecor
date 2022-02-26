local realchess = {}
local S = minetest.get_translator("xdecor")
local FS = function(...) return minetest.formspec_escape(S(...)) end
local ALPHA_OPAQUE = minetest.features.use_texture_alpha_string_modes and "opaque" or false
screwdriver = screwdriver or {}

local function index_to_xy(idx)
	if not idx then
		return nil
	end

	idx = idx - 1

	local x = idx % 8
	local y = (idx - x) / 8

	return x, y
end

local function xy_to_index(x, y)
	return x + y * 8 + 1
end

local function get_square(a, b)
	return (a * 8) - (8 - b)
end

local chat_prefix = minetest.colorize("#FFFF00", "["..S("Chess").."] ")
local letters = {'A','B','C','D','E','F','G','H'}

local function board_to_table(inv)
	local t = {}
	for i = 1, 64 do
		t[#t + 1] = inv:get_stack("board", i):get_name()
	end

	return t
end

local piece_values = {
	pawn   = 10,
	knight = 30,
	bishop = 30,
	rook   = 50,
	queen  = 90,
	king   = 900
}

local function get_possible_moves(board, from_idx)
	local piece, color = board[from_idx]:match(":(%w+)_(%w+)")
	if not piece then return end
	local moves = {}
	local from_x, from_y = index_to_xy(from_idx)

	for i = 1, 64 do
		local stack_name = board[i]
		if stack_name:find((color == "black" and "white" or "black")) or
				stack_name == "" then
			moves[i] = 0
		end
	end

	for to_idx in pairs(moves) do
		local pieceTo    = board[to_idx]
		local to_x, to_y = index_to_xy(to_idx)

		-- PAWN
		if piece == "pawn" then
			if color == "white" then
				local pawnWhiteMove = board[xy_to_index(from_x, from_y - 1)]
				-- white pawns can go up only
				if from_y - 1 == to_y then
					if from_x == to_x then
						if pieceTo ~= "" then
							moves[to_idx] = nil
						end
					elseif from_x - 1 == to_x or from_x + 1 == to_x then
						if not pieceTo:find("black") then
							moves[to_idx] = nil
						end
					else
						moves[to_idx] = nil
					end
				elseif from_y - 2 == to_y then
					if pieceTo ~= "" or from_y < 6 or pawnWhiteMove ~= "" then
						moves[to_idx] = nil
					end
				else
					moves[to_idx] = nil
				end

				--[[
				     if x not changed
				          ensure that destination cell is empty
				     elseif x changed one unit left or right
				          ensure the pawn is killing opponent piece
				     else
				          move is not legal - abort
				]]

				if from_x == to_x then
					if pieceTo ~= "" then
						moves[to_idx] = nil
					end
				elseif from_x - 1 == to_x or from_x + 1 == to_x then
					if not pieceTo:find("black") then
						moves[to_idx] = nil
					end
				else
					moves[to_idx] = nil
				end

			elseif color == "black" then
				local pawnBlackMove = board[xy_to_index(from_x, from_y + 1)]
				-- black pawns can go down only
				if from_y + 1 == to_y then
					if from_x == to_x then
						if pieceTo ~= "" then
							moves[to_idx] = nil
						end
					elseif from_x - 1 == to_x or from_x + 1 == to_x then
						if not pieceTo:find("white") then
							moves[to_idx] = nil
						end
					else
						moves[to_idx] = nil
					end
				elseif from_y + 2 == to_y then
					if pieceTo ~= "" or from_y > 1 or pawnBlackMove ~= "" then
						moves[to_idx] = nil
					end
				else
					moves[to_idx] = nil
				end

				--[[
				     if x not changed
				          ensure that destination cell is empty
				     elseif x changed one unit left or right
				          ensure the pawn is killing opponent piece
				     else
				          move is not legal - abort
				]]

				if from_x == to_x then
					if pieceTo ~= "" then
						moves[to_idx] = nil
					end
				elseif from_x - 1 == to_x or from_x + 1 == to_x then
					if not pieceTo:find("white") then
						moves[to_idx] = nil
					end
				else
					moves[to_idx] = nil
				end
			else
				moves[to_idx] = nil
			end

		-- ROOK
		elseif piece == "rook" then
			if from_x == to_x then
				-- Moving vertically
				if from_y < to_y then
					-- Moving down
					-- Ensure that no piece disturbs the way
					for i = from_y + 1, to_y - 1 do
						if board[xy_to_index(from_x, i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				else
					-- Mocing up
					-- Ensure that no piece disturbs the way
					for i = to_y + 1, from_y - 1 do
						if board[xy_to_index(from_x, i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				end
			elseif from_y == to_y then
				-- Mocing horizontally
				if from_x < to_x then
					-- mocing right
					-- ensure that no piece disturbs the way
					for i = from_x + 1, to_x - 1 do
						if board[xy_to_index(i, from_y)] ~= "" then
							moves[to_idx] = nil
						end
					end
				else
					-- Mocing left
					-- Ensure that no piece disturbs the way
					for i = to_x + 1, from_x - 1 do
						if board[xy_to_index(i, from_y)] ~= "" then
							moves[to_idx] = nil
						end
					end
				end
			else
				-- Attempt to move arbitrarily -> abort
				moves[to_idx] = nil
			end

		-- KNIGHT
		elseif piece == "knight" then
			-- Get relative pos
			local dx = from_x - to_x
			local dy = from_y - to_y

			-- Get absolute values
			if dx < 0 then
				dx = -dx
			end

			if dy < 0 then
				dy = -dy
			end

			-- Sort x and y
			if dx > dy then
				dx, dy = dy, dx
			end

			-- Ensure that dx == 1 and dy == 2
			if dx ~= 1 or dy ~= 2 then
				moves[to_idx] = nil
			end
			-- Just ensure that destination cell does not contain friend piece
			-- ^ It was done already thus everything ok

		-- BISHOP
		elseif piece == "bishop" then
			-- Get relative pos
			local dx = from_x - to_x
			local dy = from_y - to_y

			-- Get absolute values
			if dx < 0 then
				dx = -dx
			end

			if dy < 0 then
				dy = -dy
			end

			-- Ensure dx and dy are equal
			if dx ~= dy then
				moves[to_idx] = nil
			end

			if from_x < to_x then
				if from_y < to_y then
					-- Moving right-down
					-- Ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x + i, from_y + i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				else
					-- Moving right-up
					-- Ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x + i, from_y - i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				end
			else
				if from_y < to_y then
					-- Moving left-down
					-- Ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x - i, from_y + i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				else
					-- Moving left-up
					-- ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x - i, from_y - i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				end
			end

		-- QUEEN
		elseif piece == "queen" then
			local dx = from_x - to_x
			local dy = from_y - to_y

			-- Get absolute values
			if dx < 0 then
				dx = -dx
			end

			if dy < 0 then
				dy = -dy
			end

			-- Ensure valid relative move
			if dx ~= 0 and dy ~= 0 and dx ~= dy then
				moves[to_idx] = nil
			end

			if from_x == to_x then
				-- Moving vertically
				if from_y < to_y then
					-- Moving down
					-- Ensure that no piece disturbs the way
					for i = from_y + 1, to_y - 1 do
						if board[xy_to_index(from_x, i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				else
					-- Mocing up
					-- Ensure that no piece disturbs the way
					for i = to_y + 1, from_y - 1 do
						if board[xy_to_index(from_x, i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				end
			elseif from_x < to_x then
				if from_y == to_y then
					-- Goes right
					-- Ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x + i, from_y)] ~= "" then
							moves[to_idx] = nil
						end
					end
				elseif from_y < to_y then
					-- Goes right-down
					-- Ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x + i, from_y + i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				else
					-- Goes right-up
					-- Ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x + i, from_y - i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				end
			else
				if from_y == to_y then
					-- Mocing horizontally
					if from_x < to_x then
						-- mocing right
						-- ensure that no piece disturbs the way
						for i = from_x + 1, to_x - 1 do
							if board[xy_to_index(i, from_y)] ~= "" then
								moves[to_idx] = nil
							end
						end
					else
						-- Mocing left
						-- Ensure that no piece disturbs the way
						for i = to_x + 1, from_x - 1 do
							if board[xy_to_index(i, from_y)] ~= "" then
								moves[to_idx] = nil
							end
						end
					end
				elseif from_y < to_y then
					-- Goes left-down
					-- Ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x - i, from_y + i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				else
					-- Goes left-up
					-- Ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x - i, from_y - i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				end
			end

		-- KING
		elseif piece == "king" then
			local dx = from_x - to_x
			local dy = from_y - to_y

			if dx < 0 then
				dx = -dx
			end

			if dy < 0 then
				dy = -dy
			end

			if dx > 1 or dy > 1 then
				moves[to_idx] = nil
			end
		end
	end

	if not next(moves) then return end

	for i in pairs(moves) do
		local stack_name = board[tonumber(i)]
		if stack_name ~= "" then
			for p, value in pairs(piece_values) do
				if stack_name:find(p) then
					moves[i] = value
				end
			end
		end
	end

	return moves
end

local function best_move(moves)
	local value, choices = 0, {}

	for from, _ in pairs(moves) do
	for to, val in pairs(_) do
		if val > value then
			value = val
			choices = {{
				from = from,
				to = to
			}}
		elseif val == value then
			choices[#choices + 1] = {
				from = from,
				to = to
			}
		end
	end
	end

	local random = math.random(1, #choices)
	local choice_from, choice_to = choices[random].from, choices[random].to

	return tonumber(choice_from), choice_to
end

local rowDirs = {-1, -1, -1, 0, 0, 1, 1, 1}
local colDirs = {-1, 0, 1, -1, 1, -1, 0, 1}

local rowDirsKnight = { 2,  1, 2, 1, -2, -1, -2, -1}
local colDirsKnight = {-1, -2, 1, 2,  1,  2, -1, -2}

local bishopThreats = {true,  false, true,  false, false, true,  false, true}
local rookThreats   = {false, true,  false, true,  true,  false, true,  false}
local queenThreats  = {true,  true,  true,  true,  true,  true,  true,  true}
local kingThreats   = {true,  true,  true,  true,  true,  true,  true,  true}

local function attacked(color, idx, board)
	local threatDetected = false
	local kill           = color == "white"
	local pawnThreats    = {kill, false, kill, false, false, not kill, false, not kill}

	for dir = 1, 8 do
		if not threatDetected then
			local col, row = index_to_xy(idx)
			col, row = col + 1, row + 1

			for step = 1, 8 do
				row = row + rowDirs[dir]
				col = col + colDirs[dir]

				if row >= 1 and row <= 8 and col >= 1 and col <= 8 then
					local square            = get_square(row, col)
					local square_name       = board[square]
					local piece, pieceColor = square_name:match(":(%w+)_(%w+)")

					if piece then
						if pieceColor ~= color then
							if piece == "bishop" and bishopThreats[dir] then
								threatDetected = true
							elseif piece == "rook" and rookThreats[dir] then
								threatDetected = true
							elseif piece == "queen" and queenThreats[dir] then
								threatDetected = true
							else
								if step == 1 then
									if piece == "pawn" and pawnThreats[dir] then
										threatDetected = true
									end
									if piece == "king" and kingThreats[dir] then
										threatDetected = true
									end
								end
							end
						end
						break
					end
				end
			end

			local colK, rowK = index_to_xy(idx)
			colK, rowK = colK + 1, rowK + 1
			rowK = rowK + rowDirsKnight[dir]
			colK = colK + colDirsKnight[dir]

			if rowK >= 1 and rowK <= 8 and colK >= 1 and colK <= 8 then
				local square            = get_square(rowK, colK)
				local square_name       = board[square]
				local piece, pieceColor = square_name:match(":(%w+)_(%w+)")

				if piece and pieceColor ~= color and piece == "knight" then
					threatDetected = true
				end
			end
		end
	end

	return threatDetected
end

local function locate_kings(board)
	local Bidx, Widx
	for i = 1, 64 do
		local piece, color = board[i]:match(":(%w+)_(%w+)")
		if piece == "king" then
			if color == "black" then
				Bidx = i
			else
				Widx = i
			end
		end
	end

	return Bidx, Widx
end

local pieces = {
	"realchess:rook_black_1",
	"realchess:knight_black_1",
	"realchess:bishop_black_1",
	"realchess:queen_black",
	"realchess:king_black",
	"realchess:bishop_black_2",
	"realchess:knight_black_2",
	"realchess:rook_black_2",
	"realchess:pawn_black_1",
	"realchess:pawn_black_2",
	"realchess:pawn_black_3",
	"realchess:pawn_black_4",
	"realchess:pawn_black_5",
	"realchess:pawn_black_6",
	"realchess:pawn_black_7",
	"realchess:pawn_black_8",
	'','','','','','','','','','','','','','','','',
	'','','','','','','','','','','','','','','','',
	"realchess:pawn_white_1",
	"realchess:pawn_white_2",
	"realchess:pawn_white_3",
	"realchess:pawn_white_4",
	"realchess:pawn_white_5",
	"realchess:pawn_white_6",
	"realchess:pawn_white_7",
	"realchess:pawn_white_8",
	"realchess:rook_white_1",
	"realchess:knight_white_1",
	"realchess:bishop_white_1",
	"realchess:queen_white",
	"realchess:king_white",
	"realchess:bishop_white_2",
	"realchess:knight_white_2",
	"realchess:rook_white_2"
}

local pieces_str, x = "", 0
for i = 1, #pieces do
	local p = pieces[i]:match(":(%w+_%w+)")
	if pieces[i]:find(":(%w+)_(%w+)") and not pieces_str:find(p) then
		pieces_str = pieces_str .. x .. "=" .. p .. ".png,"
		x = x + 1
	end
end
pieces_str = pieces_str .. "69=mailbox_blank16.png"

local fs_init = [[
	size[4,1.2;]
	no_prepend[]
	]]
	.."label[0,0;"..FS("Select a mode:").."]"
	.."button[0,0.5;2,1;single;"..FS("Singleplayer").."]"
	.."button[2,0.5;2,1;multi;"..FS("Multiplayer").."]"

local fs = [[
	size[14.7,10;]
	no_prepend[]
	bgcolor[#080808BB;true]
	background[0,0;14.7,10;chess_bg.png]
	list[context;board;0.3,1;8,8;]
	listcolors[#00000000;#00000000;#00000000;#30434C;#FFF]
	tableoptions[background=#00000000;highlight=#00000000;border=false]
	]]
	.."button[10.5,8.5;2,2;new;"..FS("New game").."]"
	.."tablecolumns[image," .. pieces_str ..
		";text;color;text;color;text;image," .. pieces_str .. "]"

local function update_formspec(meta)
	local black_king_attacked = meta:get_string("blackAttacked") == "true"
	local white_king_attacked = meta:get_string("whiteAttacked") == "true"

	local playerWhite = meta:get_string("playerWhite")
	local playerBlack = meta:get_string("playerBlack")

	local moves     = meta:get_string("moves")
	local eaten_img = meta:get_string("eaten_img")
	local lastMove  = meta:get_string("lastMove")
	local turnBlack = minetest.colorize("#000001", (lastMove == "white" and playerBlack ~= "") and
			  playerBlack .. "..." or playerBlack)
	local turnWhite = minetest.colorize("#000001", (lastMove == "black" and playerWhite ~= "") and
			  playerWhite .. "..." or playerWhite)
	local check_s   = minetest.colorize("#FF0000", "\\["..FS("check").."\\]")

	local formspec = fs ..
		"label[1.9,0.3;"  .. turnBlack .. (black_king_attacked and " " .. check_s or "") .. "]" ..
		"label[1.9,9.15;" .. turnWhite .. (white_king_attacked and " " .. check_s or "") .. "]" ..
		"table[8.9,1.05;5.07,3.75;moves;" .. moves:sub(1,-2) .. ";1]" ..
		eaten_img

	meta:set_string("formspec", formspec)
end

local function get_moves_list(meta, pieceFrom, pieceTo, pieceTo_s, from_idx, to_idx)
	local from_x, from_y  = index_to_xy(from_idx)
	local to_x, to_y      = index_to_xy(to_idx)
	local moves           = meta:get_string("moves")
	local pieceFrom_s     = pieceFrom:match(":(%w+_%w+)")
	local pieceFrom_si_id = pieces_str:match("(%d+)=" .. pieceFrom_s)
	local pieceTo_si_id   = pieceTo_s ~= "" and pieces_str:match("(%d+)=" .. pieceTo_s) or ""

	local coordFrom = letters[from_x + 1] .. math.abs(from_y - 8)
	local coordTo   = letters[to_x   + 1] .. math.abs(to_y   - 8)

	local new_moves = pieceFrom_si_id .. "," ..
		coordFrom .. "," ..
			(pieceTo ~= "" and "#33FF33" or "#FFFFFF") .. ", > ,#FFFFFF," ..
		coordTo .. "," ..
		(pieceTo ~= "" and pieceTo_si_id or "69") .. "," ..
		moves

	meta:set_string("moves", new_moves)
end

local function get_eaten_list(meta, pieceTo, pieceTo_s)
	local eaten = meta:get_string("eaten")
	if pieceTo ~= "" then
		eaten = eaten .. pieceTo_s .. ","
	end

	meta:set_string("eaten", eaten)

	local eaten_t   = string.split(eaten, ",")
	local eaten_img = ""

	local a, b = 0, 0
	for i = 1, #eaten_t do
		local is_white = eaten_t[i]:sub(-5,-1) == "white"
		local X = (is_white and a or b) % 4
		local Y = ((is_white and a or b) % 16 - X) / 4

		if is_white then
			a = a + 1
		else
			b = b + 1
		end

		eaten_img = eaten_img ..
			"image[" .. ((X + (is_white and 11.67 or 8.8)) - (X * 0.45)) .. "," ..
				    ((Y + 5.56) - (Y * 0.2)) .. ";1,1;" .. eaten_t[i] .. ".png]"
	end

	meta:set_string("eaten_img", eaten_img)
end

function realchess.init(pos)
	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()

	meta:set_string("formspec", fs_init)
	meta:set_string("infotext", S("Chess Board"))
	meta:set_string("playerBlack", "")
	meta:set_string("playerWhite", "")
	meta:set_string("lastMove",    "")
	meta:set_string("blackAttacked", "")
	meta:set_string("whiteAttacked", "")

	meta:set_int("lastMoveTime",   0)
	meta:set_int("castlingBlackL", 1)
	meta:set_int("castlingBlackR", 1)
	meta:set_int("castlingWhiteL", 1)
	meta:set_int("castlingWhiteR", 1)

	meta:set_string("moves", "")
	meta:set_string("eaten", "")
	meta:set_string("mode", "")

	inv:set_list("board", pieces)
	inv:set_size("board", 64)
end

function realchess.move(pos, from_list, from_index, to_list, to_index, _, player)
	if from_list ~= "board" and to_list ~= "board" then
		return 0
	end

	local meta        = minetest.get_meta(pos)
	local playerName  = player:get_player_name()
	local inv         = meta:get_inventory()
	local pieceFrom   = inv:get_stack(from_list, from_index):get_name()
	local pieceTo     = inv:get_stack(to_list, to_index):get_name()
	local lastMove    = meta:get_string("lastMove")
	local playerWhite = meta:get_string("playerWhite")
	local playerBlack = meta:get_string("playerBlack")
	local thisMove    -- Will replace lastMove when move is legal

	if pieceFrom:find("white") then
		if playerWhite ~= "" and playerWhite ~= playerName then
			minetest.chat_send_player(playerName, chat_prefix .. S("Someone else plays white pieces!"))
			return 0
		end

		if lastMove ~= "" and lastMove ~= "black" then
			return 0
		end

		if pieceTo:find("white") then
			-- Don't replace pieces of same color
			return 0
		end

		playerWhite = playerName
		thisMove = "white"

	elseif pieceFrom:find("black") then
		if playerBlack ~= "" and playerBlack ~= playerName then
			minetest.chat_send_player(playerName, chat_prefix .. S("Someone else plays black pieces!"))
			return 0
		end

		if lastMove ~= "" and lastMove ~= "white" then
			return 0
		end

		if pieceTo:find("black") then
			-- Don't replace pieces of same color
			return 0
		end

		playerBlack = playerName
		thisMove = "black"
	end

	-- MOVE LOGIC

	local from_x, from_y = index_to_xy(from_index)
	local to_x, to_y     = index_to_xy(to_index)

	-- PAWN
	if pieceFrom:sub(11,14) == "pawn" then
		if thisMove == "white" then
			local pawnWhiteMove = inv:get_stack(from_list, xy_to_index(from_x, from_y - 1)):get_name()
			-- white pawns can go up only
			if from_y - 1 == to_y then
				if from_x == to_x then
					if pieceTo ~= "" then
						return 0
					elseif to_index >= 1 and to_index <= 8 then
						inv:set_stack(from_list, from_index, "realchess:queen_white")
					end
				elseif from_x - 1 == to_x or from_x + 1 == to_x then
					if not pieceTo:find("black") then
						return 0
					elseif to_index >= 1 and to_index <= 8 then
						inv:set_stack(from_list, from_index, "realchess:queen_white")
					end
				else
					return 0
				end
			elseif from_y - 2 == to_y then
				if pieceTo ~= "" or from_y < 6 or pawnWhiteMove ~= "" then
					return 0
				end
			else
				return 0
			end

			--[[
			     if x not changed
			          ensure that destination cell is empty
			     elseif x changed one unit left or right
			          ensure the pawn is killing opponent piece
			     else
			          move is not legal - abort
			]]

			if from_x == to_x then
				if pieceTo ~= "" then
					return 0
				end
			elseif from_x - 1 == to_x or from_x + 1 == to_x then
				if not pieceTo:find("black") then
					return 0
				end
			else
				return 0
			end

		elseif thisMove == "black" then
			local pawnBlackMove = inv:get_stack(from_list, xy_to_index(from_x, from_y + 1)):get_name()
			-- black pawns can go down only
			if from_y + 1 == to_y then
				if from_x == to_x then
					if pieceTo ~= "" then
						return 0
					elseif to_index >= 57 and to_index <= 64 then
						inv:set_stack(from_list, from_index, "realchess:queen_black")
					end
				elseif from_x - 1 == to_x or from_x + 1 == to_x then
					if not pieceTo:find("white") then
						return 0
					elseif to_index >= 57 and to_index <= 64 then
						inv:set_stack(from_list, from_index, "realchess:queen_black")
					end
				else
					return 0
				end
			elseif from_y + 2 == to_y then
				if pieceTo ~= "" or from_y > 1 or pawnBlackMove ~= "" then
					return 0
				end
			else
				return 0
			end

			--[[
			     if x not changed
			          ensure that destination cell is empty
			     elseif x changed one unit left or right
			          ensure the pawn is killing opponent piece
			     else
			          move is not legal - abort
			]]

			if from_x == to_x then
				if pieceTo ~= "" then
					return 0
				end
			elseif from_x - 1 == to_x or from_x + 1 == to_x then
				if not pieceTo:find("white") then
					return 0
				end
			else
				return 0
			end
		else
			return 0
		end

	-- ROOK
	elseif pieceFrom:sub(11,14) == "rook" then
		if from_x == to_x then
			-- Moving vertically
			if from_y < to_y then
				-- Moving down
				-- Ensure that no piece disturbs the way
				for i = from_y + 1, to_y - 1 do
					if inv:get_stack(from_list, xy_to_index(from_x, i)):get_name() ~= "" then
						return 0
					end
				end
			else
				-- Mocing up
				-- Ensure that no piece disturbs the way
				for i = to_y + 1, from_y - 1 do
					if inv:get_stack(from_list, xy_to_index(from_x, i)):get_name() ~= "" then
						return 0
					end
				end
			end
		elseif from_y == to_y then
			-- Mocing horizontally
			if from_x < to_x then
				-- mocing right
				-- ensure that no piece disturbs the way
				for i = from_x + 1, to_x - 1 do
					if inv:get_stack(from_list, xy_to_index(i, from_y)):get_name() ~= "" then
						return 0
					end
				end
			else
				-- Mocing left
				-- Ensure that no piece disturbs the way
				for i = to_x + 1, from_x - 1 do
					if inv:get_stack(from_list, xy_to_index(i, from_y)):get_name() ~= "" then
						return 0
					end
				end
			end
		else
			-- Attempt to move arbitrarily -> abort
			return 0
		end

		if thisMove == "white" or thisMove == "black" then
			if pieceFrom:sub(-1) == "1" then
				meta:set_int("castlingWhiteL", 0)
			elseif pieceFrom:sub(-1) == "2" then
				meta:set_int("castlingWhiteR", 0)
			end
		end

	-- KNIGHT
	elseif pieceFrom:sub(11,16) == "knight" then
		-- Get relative pos
		local dx = from_x - to_x
		local dy = from_y - to_y

		-- Get absolute values
		if dx < 0 then dx = -dx end
		if dy < 0 then dy = -dy end

		-- Sort x and y
		if dx > dy then dx, dy = dy, dx end

		-- Ensure that dx == 1 and dy == 2
		if dx ~= 1 or dy ~= 2 then
			return 0
		end
		-- Just ensure that destination cell does not contain friend piece
		-- ^ It was done already thus everything ok

	-- BISHOP
	elseif pieceFrom:sub(11,16) == "bishop" then
		-- Get relative pos
		local dx = from_x - to_x
		local dy = from_y - to_y

		-- Get absolute values
		if dx < 0 then dx = -dx end
		if dy < 0 then dy = -dy end

		-- Ensure dx and dy are equal
		if dx ~= dy then return 0 end

		if from_x < to_x then
			if from_y < to_y then
				-- Moving right-down
				-- Ensure that no piece disturbs the way
				for i = 1, dx - 1 do
					if inv:get_stack(
						from_list, xy_to_index(from_x + i, from_y + i)):get_name() ~= "" then
						return 0
					end
				end
			else
				-- Moving right-up
				-- Ensure that no piece disturbs the way
				for i = 1, dx - 1 do
					if inv:get_stack(
						from_list, xy_to_index(from_x + i, from_y - i)):get_name() ~= "" then
						return 0
					end
				end
			end
		else
			if from_y < to_y then
				-- Moving left-down
				-- Ensure that no piece disturbs the way
				for i = 1, dx - 1 do
					if inv:get_stack(
						from_list, xy_to_index(from_x - i, from_y + i)):get_name() ~= "" then
						return 0
					end
				end
			else
				-- Moving left-up
				-- ensure that no piece disturbs the way
				for i = 1, dx - 1 do
					if inv:get_stack(
						from_list, xy_to_index(from_x - i, from_y - i)):get_name() ~= "" then
						return 0
					end
				end
			end
		end

	-- QUEEN
	elseif pieceFrom:sub(11,15) == "queen" then
		local dx = from_x - to_x
		local dy = from_y - to_y

		-- Get absolute values
		if dx < 0 then dx = -dx end
		if dy < 0 then dy = -dy end

		-- Ensure valid relative move
		if dx ~= 0 and dy ~= 0 and dx ~= dy then
			return 0
		end

		if from_x == to_x then
			if from_y < to_y then
				-- Goes down
				-- Ensure that no piece disturbs the way
				for i = from_y + 1, to_y - 1 do
					if inv:get_stack(from_list, xy_to_index(from_x, i)):get_name() ~= "" then
						return 0
					end
				end
			else
				-- Goes up
				-- Ensure that no piece disturbs the way
				for i = to_y + 1, from_y - 1 do
					if inv:get_stack(from_list, xy_to_index(from_x, i)):get_name() ~= "" then
						return 0
					end
				end
			end
		elseif from_x < to_x then
			if from_y == to_y then
				-- Goes right
				-- Ensure that no piece disturbs the way
				for i = from_x + 1, to_x - 1 do
					if inv:get_stack(from_list, xy_to_index(i, from_y)):get_name() ~= "" then
						return 0
					end
				end
			elseif from_y < to_y then
				-- Goes right-down
				-- Ensure that no piece disturbs the way
				for i = 1, dx - 1 do
					if inv:get_stack(
						from_list, xy_to_index(from_x + i, from_y + i)):get_name() ~= "" then
						return 0
					end
				end
			else
				-- Goes right-up
				-- Ensure that no piece disturbs the way
				for i = 1, dx - 1 do
					if inv:get_stack(
						from_list, xy_to_index(from_x + i, from_y - i)):get_name() ~= "" then
						return 0
					end
				end
			end
		else
			if from_y == to_y then
				-- Goes left
				-- Ensure that no piece disturbs the way and destination cell does
				for i = to_x + 1, from_x - 1 do
					if inv:get_stack(from_list, xy_to_index(i, from_y)):get_name() ~= "" then
						return 0
					end
				end
			elseif from_y < to_y then
				-- Goes left-down
				-- Ensure that no piece disturbs the way
				for i = 1, dx - 1 do
					if inv:get_stack(
						from_list, xy_to_index(from_x - i, from_y + i)):get_name() ~= "" then
						return 0
					end
				end
			else
				-- Goes left-up
				-- Ensure that no piece disturbs the way
				for i = 1, dx - 1 do
					if inv:get_stack(
						from_list, xy_to_index(from_x - i, from_y - i)):get_name() ~= "" then
						return 0
					end
				end
			end
		end

	-- KING
	elseif pieceFrom:sub(11,14) == "king" then
		local dx = from_x - to_x
		local dy = from_y - to_y
		local check = true

		if thisMove == "white" then
			if from_y == 7 and to_y == 7 then
				if to_x == 2 then
					local castlingWhiteL = meta:get_int("castlingWhiteL")
					local idx57 = inv:get_stack(from_list, 57):get_name()

					if castlingWhiteL == 1 and idx57 == "realchess:rook_white_1" then
						for i = 58, from_index - 1 do
							if inv:get_stack(from_list, i):get_name() ~= "" then
								return 0
							end
						end

						inv:set_stack(from_list, 57, "")
						inv:set_stack(from_list, 60, "realchess:rook_white_1")
						check = false
					end
				elseif to_x == 6 then
					local castlingWhiteR = meta:get_int("castlingWhiteR")
					local idx64 = inv:get_stack(from_list, 64):get_name()

					if castlingWhiteR == 1 and idx64 == "realchess:rook_white_2" then
						for i = from_index + 1, 63 do
							if inv:get_stack(from_list, i):get_name() ~= "" then
								return 0
							end
						end

						inv:set_stack(from_list, 62, "realchess:rook_white_2")
						inv:set_stack(from_list, 64, "")
						check = false
					end
				end
			end
		elseif thisMove == "black" then
			if from_y == 0 and to_y == 0 then
				if to_x == 2 then
					local castlingBlackL = meta:get_int("castlingBlackL")
					local idx1 = inv:get_stack(from_list, 1):get_name()

					if castlingBlackL == 1 and idx1 == "realchess:rook_black_1" then
						for i = 2, from_index - 1 do
							if inv:get_stack(from_list, i):get_name() ~= "" then
								return 0
							end
						end

						inv:set_stack(from_list, 1, "")
						inv:set_stack(from_list, 4, "realchess:rook_black_1")
						check = false
					end
				elseif to_x == 6 then
					local castlingBlackR = meta:get_int("castlingBlackR")
					local idx8 = inv:get_stack(from_list, 8):get_name()

					if castlingBlackR == 1 and idx8 == "realchess:rook_black_2" then
						for i = from_index + 1, 7 do
							if inv:get_stack(from_list, i):get_name() ~= "" then
								return 0
							end
						end

						inv:set_stack(from_list, 6, "realchess:rook_black_2")
						inv:set_stack(from_list, 8, "")
						check = false
					end
				end
			end
		end

		if check then
			if dx < 0 then
				dx = -dx
			end

			if dy < 0 then
				dy = -dy
			end

			if dx > 1 or dy > 1 then
				return 0
			end
		end

		if thisMove == "white" then
			meta:set_int("castlingWhiteL", 0)
			meta:set_int("castlingWhiteR", 0)

		elseif thisMove == "black" then
			meta:set_int("castlingBlackL", 0)
			meta:set_int("castlingBlackR", 0)
		end
	end

	local board       = board_to_table(inv)
	board[to_index]   = board[from_index]
	board[from_index] = ""

	local black_king_idx, white_king_idx = locate_kings(board)
	if not black_king_idx or not white_king_idx then
		return 0
	end
	local blackAttacked = attacked("black", black_king_idx, board)
	local whiteAttacked = attacked("white", white_king_idx, board)

	if blackAttacked then
		if thisMove == "black" then
			--[(*)[ and meta:get_string("blackAttacked") == "true" ]] then
			return 0
		else
			meta:set_string("blackAttacked", "true")
		end
	else
		meta:set_string("blackAttacked", "")
	end

	if whiteAttacked then
		if thisMove == "white" then
			--[(*)[ and meta:get_string("whiteAttacked") == "true" ]] then
			return 0
		else
			meta:set_string("whiteAttacked", "true")
		end
	else
		meta:set_string("whiteAttacked", "")
	end

	--(*) Allow a piece to move and put its king in check. Maybe not in the chess rules though?

	lastMove = thisMove
	meta:set_string("lastMove", lastMove)
	meta:set_int("lastMoveTime", minetest.get_gametime())

	if meta:get_string("playerWhite") == "" then
		meta:set_string("playerWhite", playerWhite)
	elseif meta:get_string("playerBlack") == "" then
		meta:set_string("playerBlack", playerBlack)
	end

	local pieceTo_s = pieceTo ~= "" and pieceTo:match(":(%w+_%w+)") or ""
	get_moves_list(meta, pieceFrom, pieceTo, pieceTo_s, from_index, to_index)
	get_eaten_list(meta, pieceTo, pieceTo_s)

	return 1
end

local function ai_move(inv, meta)
	local board_t = board_to_table(inv)
	local lastMove = meta:get_string("lastMove")

	if lastMove == "white" then
		update_formspec(meta)
		local moves = {}

		for i = 1, 64 do
			local possibleMoves = get_possible_moves(board_t, i)
			local stack_name    = inv:get_stack("board", i):get_name()

			if stack_name:find("black") then
				moves[tostring(i)] = possibleMoves
			end
		end

		local choice_from, choice_to = best_move(moves)

		local pieceFrom = inv:get_stack("board", choice_from):get_name()
		local pieceTo   = inv:get_stack("board", choice_to):get_name()
		local pieceTo_s = pieceTo ~= "" and pieceTo:match(":(%w+_%w+)") or ""

		local board          = board_to_table(inv)
		local black_king_idx = locate_kings(board)
		local blackAttacked  = attacked("black", black_king_idx, board)
		local kingSafe       = true
		local bestMoveSaveFrom, bestMoveSaveTo

		if blackAttacked then
			kingSafe = false
			meta:set_string("blackAttacked", "true")
			local save_moves = {}

			for from_idx, _ in pairs(moves) do
			for to_idx, value in pairs(_) do
				from_idx = tonumber(from_idx)
				local from_idx_bak, to_idx_bak = board[from_idx], board[to_idx]
				board[to_idx]   = board[from_idx]
				board[from_idx] = ""
				black_king_idx  = locate_kings(board)

				if black_king_idx then
					blackAttacked = attacked("black", black_king_idx, board)
					if not blackAttacked then
						save_moves[from_idx] = save_moves[from_idx] or {}
						save_moves[from_idx][to_idx] = value
					end
				end

				board[from_idx], board[to_idx] = from_idx_bak, to_idx_bak
			end
			end

			if next(save_moves) then
				bestMoveSaveFrom, bestMoveSaveTo = best_move(save_moves)
			end
		end

		minetest.after(1.0, function()
			local lastMoveTime = meta:get_int("lastMoveTime")
			if lastMoveTime > 0 then
				if not kingSafe then
					if bestMoveSaveTo then
						inv:set_stack("board", bestMoveSaveTo, board[bestMoveSaveFrom])
						inv:set_stack("board", bestMoveSaveFrom, "")
						meta:set_string("blackAttacked", "")
					else
						return
					end
				else
					if pieceFrom:find("pawn") and choice_to >= 57 and choice_to <= 64 then
						inv:set_stack("board", choice_to, "realchess:queen_black")
					else
						inv:set_stack("board", choice_to, pieceFrom)
					end

					inv:set_stack("board", choice_from, "")
				end

				board = board_to_table(inv)
				local _, white_king_idx = locate_kings(board)
				local whiteAttacked = attacked("white", white_king_idx, board)

				if whiteAttacked then
					meta:set_string("whiteAttacked", "true")
				end

				if meta:get_string("playerBlack") == "" then
					meta:set_string("playerBlack", S("Dumb AI"))
				end

				meta:set_string("lastMove", "black")
				meta:set_int("lastMoveTime", minetest.get_gametime())

				get_moves_list(meta, pieceFrom, pieceTo, pieceTo_s, choice_from, choice_to)
				get_eaten_list(meta, pieceTo, pieceTo_s)

				update_formspec(meta)
			end
		end)
	else
		update_formspec(meta)
	end
end

function realchess.on_move(pos, from_list, from_index)
	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()
	inv:set_stack(from_list, from_index, "")

	if meta:get_string("mode") == "single" then
		ai_move(inv, meta)
	end

	return false
end

local function timeout_format(timeout_limit)
	local time_remaining = timeout_limit - minetest.get_gametime()
	local minutes        = math.floor(time_remaining / 60)
	local seconds        = time_remaining % 60

	if minutes == 0 then
		return seconds .. " sec."
	end

	return minutes .. " min. " .. seconds .. " sec."
end

function realchess.fields(pos, _, fields, sender)
	local playerName    = sender:get_player_name()
	local meta          = minetest.get_meta(pos)
	local timeout_limit = meta:get_int("lastMoveTime") + 300
	local playerWhite   = meta:get_string("playerWhite")
	local playerBlack   = meta:get_string("playerBlack")
	local lastMoveTime  = meta:get_int("lastMoveTime")
	if fields.quit then return end

	if fields.single or fields.multi then
		meta:set_string("mode", (fields.single and "single" or "multi"))
		update_formspec(meta)
		return
	end

	-- Timeout is 5 min. by default for resetting the game (non-players only)
	if fields.new then
		if (playerWhite == playerName or playerBlack == playerName) then
			realchess.init(pos)

		elseif lastMoveTime > 0 then
			if minetest.get_gametime() >= timeout_limit and
					(playerWhite ~= playerName or playerBlack ~= playerName) then
				realchess.init(pos)
			else
				minetest.chat_send_player(playerName, chat_prefix ..
					S("You can't reset the chessboard, a game has been started. " ..
					"If you aren't a current player, try again in @1",
					timeout_format(timeout_limit)))
			end
		end
	end
end

function realchess.dig(pos, player)
	if not player then
		return false
	end

	local meta          = minetest.get_meta(pos)
	local playerName    = player:get_player_name()
	local timeout_limit = meta:get_int("lastMoveTime") + 300
	local lastMoveTime  = meta:get_int("lastMoveTime")

	-- Timeout is 5 min. by default for digging the chessboard (non-players only)
	return (lastMoveTime == 0 and minetest.get_gametime() > timeout_limit) or
		minetest.chat_send_player(playerName, chat_prefix ..
				S("You can't dig the chessboard, a game has been started. " ..
				"Reset it first if you're a current player, or dig it again in @1",
				timeout_format(timeout_limit)))
end

minetest.register_node(":realchess:chessboard", {
	description = S("Chess Board"),
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	inventory_image = "chessboard_top.png",
	wield_image = "chessboard_top.png",
	tiles = {"chessboard_top.png", "chessboard_top.png", "chessboard_sides.png"},
	use_texture_alpha = ALPHA_OPAQUE,
	groups = {choppy=3, oddly_breakable_by_hand=2, flammable=3},
	sounds = default.node_sound_wood_defaults(),
	node_box = {type = "fixed", fixed = {-.375, -.5, -.375, .375, -.4375, .375}},
	sunlight_propagates = true,
	on_rotate = screwdriver.rotate_simple,
	can_dig = realchess.dig,
	on_construct = realchess.init,
	on_receive_fields = realchess.fields,
	allow_metadata_inventory_move = realchess.move,
	on_metadata_inventory_move = realchess.on_move,
	allow_metadata_inventory_take = function() return 0 end
})

local function register_piece(name, white_desc, black_desc, count)
	for _, color in pairs({"black", "white"}) do
	if not count then
		minetest.register_craftitem(":realchess:" .. name .. "_" .. color, {
			description = (color == "black") and black_desc or white_desc,
			inventory_image = name .. "_" .. color .. ".png",
			stack_max = 1,
			groups = {not_in_creative_inventory=1}
		})
	else
		for i = 1, count do
			minetest.register_craftitem(":realchess:" .. name .. "_" .. color .. "_" .. i, {
				description = (color == "black") and black_desc or white_desc,
				inventory_image = name .. "_" .. color .. ".png",
				stack_max = 1,
				groups = {not_in_creative_inventory=1}
			})
		end
	end
	end
end

register_piece("pawn", S("White Pawn"), S("Black Pawn"), 8)
register_piece("rook", S("White Rook"), S("Black Rook"), 2)
register_piece("knight", S("White Knight"), S("Black Knight"), 2)
register_piece("bishop", S("White Bishop"), S("Black Bishop"), 2)
register_piece("queen", S("White Queen"), S("Black Queen"))
register_piece("king", S("White King"), S("Black King"))

-- Recipes

minetest.register_craft({
	output = "realchess:chessboard",
	recipe = {
		{"dye:black", "dye:white", "dye:black"},
		{"stairs:slab_wood", "stairs:slab_wood", "stairs:slab_wood"}
	}
})
