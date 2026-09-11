local M = {}

function M.diff(buf, win, opts)
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

  local hash = "" .. line:sub(line:find("=") + 1 or 0)
  print(hash)

  vim.api.nvim_win_close(win, true)
  vim.defer_fn(function()
    vim.schedule(function()
      vim.cmd("Diff " .. vim.fn.fnameescape(hash))
    end)
  end, 500)
end

function M.switch_branch(buf)
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
      "branch",
      "--points-at",
      hash,
    }, { text = true })
    :wait()

  local branches = vim.split(vim.trim(result.stdout), "\n", { trimempty = true })

  local branch = ""

  for _, branchy in ipairs(branches) do
    branch = branchy:gsub("^%* ", "")
  end

  vim.system({ "git", "switch", branch })
end

function M.merge(buf)
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
      "branch",
      "--points-at",
      hash,
    }, { text = true })
    :wait()

  local branches = vim.split(vim.trim(result.stdout), "\n", { trimempty = true })

  local branch = ""

  for _, branchy in ipairs(branches) do
    branch = branchy:gsub("^%* ", "")
  end

  vim.ui.input({ prompt = "to: " }, function(input)
    vim.system({
      "git",
      "switch",
      input,
    })
    vim.system({
      "git",
      "merge",
      branch,
    })
  end)
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
    ["_"] = true,
    ["*"] = false,
  }

  while commit_txt[char] do
    if char == "|" then
      row = row + 1
    elseif char == "/" then
      row = row + 1
      col = col - 1
    elseif char == "\\" then
    else
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
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "loading..." })

  -- Window size
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
  vim.wo[win].signcolumn = "no"

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, desc = "closes the windows" })

  local glog = opts.glog

  vim.system(glog, { text = true }, function(result)
    vim.schedule(function()
      local tree = vim.split(result.stdout, "\n", { plain = true })

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, tree)

      local baleia = require("baleia").setup({})

      baleia.once(buf)

      vim.keymap.set("n", "e", function()
        M.expand(buf)
      end, { buffer = buf, desc = "outputs commit msg" })
    end)

    vim.schedule(function()
      vim.keymap.set("n", "d", function()
        M.diff(buf, win, opts)
      end, { buffer = buf, desc = "checks the difference" })

      vim.schedule(function()
        vim.keymap.set("n", "m", function()
          M.merge(buf)
        end, { buffer = buf, desc = "merges 2 branches" })

        vim.keymap.set("n", "s", function()
          M.switch_branch(buf)
        end, { buffer = buf, desc = "switches to selected branch" })
      end)
    end)
  end)
end

M.setup = function(opts)
  opts = opts or {}

  opts.maximum_depth = opts.maximum_depth or 1000
  opts.width = opts.width or 150
  opts.height = opts.height or 30
  opts.glog = opts.glog
    or {
      "git",
      "log",
      "-n",
      tostring(opts.maximum_depth),
      "--graph",
      "--all",
      "--decorate",
      "--pretty=format:\x1b[30m=%h%Creset\x1b[0m",
      --'--date=format:"%Y-%m-%d %H:%M" ',
      "--color=always",
    }

  vim.keymap.set("n", "<leader>gu", function()
    M.ui(opts)
  end, { desc = "opens the gui" })

  vim.keymap.set("n", "<leader>gb", function()
    vim.ui.input({ prompt = "new branch name: " }, function(input)
      if input then
        vim.system({ "git", "switch", "-c", input })
      end
    end)
  end, { desc = "makes a new branch" })

  vim.keymap.set("n", "<leader>gc", function()
    vim.ui.input({ prompt = "commit msg: " }, function(input)
      vim.system({ "git", "add", "." })
      vim.system({ "git", "commit", "-m", input })
    end)
  end, { desc = "commits with given msg" })
  vim.keymap.set("n", "<leader>gp", function()
    print("pushing.......")
    vim.system({ "git", "push" }, { text = true }, function(out)
      print("done pushing")
    end)
  end, { desc = "pushes the repo" })
end

return M
