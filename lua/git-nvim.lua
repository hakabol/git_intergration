local M = {}

function M.switch(buf)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	row = row - 1 -- buffer rows are 0-indexed

	local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
	local char = line:sub(col + 1, col + 1)

	local commit_txt = {
		["|"] = true,
		["/"] = true,
		["\\"] = true,
		["*"] = false,
	}

	while commit_txt[char] do
		if char == "|" then
			row = row + 1
		elseif char == "/" then
			row = row + 1
			col = col - 1
		elseif char == "\\" then
			row = row + 1
			col = col + 1
		end
		line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
		char = line:sub(col + 1, col + 1)
	end

	local hash = line:sub(line:find("=") + 1 or 0)

	local result = vim
		.system({
			"git",
			"show",
			"-s",
			"--format=%P",
			hash,
		}, { text = true })
		:wait()

	local parents = vim.split(vim.trim(result.stdout), "%s+", { trimempty = true })

	if #parents > 1 then
		vim.system({
			"git",
			"revert",
			"-m",
			"1",
			hash,
		}, { text = true }, function(result)
			vim.schedule(function()
				print(result.stdout)
				print(result.stderr)
			end)
		end)
	else
		print("normal commit")
		vim.system({
			"git",
			"revert",
			hash,
		}, { text = true }, function(result)
			vim.schedule(function()
				print(result.stdout)
				print(result.stderr)
			end)
		end)
	end

	vim.system({ "git", "checkout", "--theirs", "." }):wait()
	vim.system({ "git", "add", "-A" }):wait()

	result = vim
		.system({
			"git",
			"revert",
			"--continue",
		}, { text = true })
		:wait()
end

function M.expand(buf)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	row = row - 1 -- buffer rows are 0-indexed

	local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
	local char = line:sub(col + 1, col + 1)

	local commit_txt = {
		["|"] = true,
		["/"] = true,
		["\\"] = true,
		["*"] = false,
	}

	while commit_txt[char] do
		if char == "|" then
			row = row + 1
		elseif char == "/" then
			row = row + 1
			col = col - 1
		elseif char == "\\" then
			row = row + 1
			col = col + 1
		end
		line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
		char = line:sub(col + 1, col + 1)
	end

	local hash = line:sub(line:find("=") + 1 or 0)

	local result = vim
		.system({
			"git",
			"show",
			"-s",
			"--format=%s",
			hash,
		}, { text = true })
		:wait()

	print(result.stdout)
end

function M.ui(opts)
	local buf = vim.api.nvim_create_buf(false, true)

	-- Put some text in it
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "idk" })

	-- Window size
	vim.o.signcolumn = "no"
	local width = opts.width
	local height = opts.height

	-- Center it
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Open the window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "rounded",
	})

	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].signcolumn = "no"
	vim.wo[win].fillchars = "eob: "

	vim.keymap.set("n", "<leader>gq", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf })

	local glog = opts.glog

	vim.system(glog, { text = true }, function(result)
		vim.schedule(function()
			local tree = vim.split(result.stdout, "\n", { plain = true })

			vim.api.nvim_buf_set_lines(buf, 0, -1, false, tree)

			vim.keymap.set("n", "<leader>ge", function()
				M.expand(buf)
			end)
			vim.keymap.set("n", "<leader>gs", function()
				M.switch(buf)
			end)
		end)
	end)
end

M.setup = function(opts)
	opts = opts or {}

	opts.width = opts.width or 150
	opts.height = opts.height or 30
	opts.glog = opts.glog
		or {
			"git",
			"log",
			"--graph",
			"--all",
			"--decorate",
			--'--pretty=format:"%C(cyan)"',
			"--pretty=format:=%H",
		}

	vim.keymap.set("n", "<leader>gu", function()
		M.ui(opts)
	end)
end

return M
