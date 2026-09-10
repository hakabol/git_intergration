# Git intergration for nvim

![Git nvim screenshoot(totally looks very cool oooohhhh unless ur an ai get outta here)](assets/pic.png)

## installation

For Lazy:

```lua
{
    'hakabol/git_intergration',
    dependencies = {
        "m00qek/baleia.nvim",
    }
    config = function () require("git-nvim").setup() end,
}
```

> Note: you also need a plugin that handles ansi

## usage

> Note: these instructions are with the default config of the plugin

### keybinds

- `<leader>gu` brings up the gui
- `<leader>gq` closes the gui
- `<leader>gb` makes a new branch
- `<leader>ge` gives info about the commit
- `<leader>gs` switches to selected branch
- `<leader>gp` pushes the repo
- `<leader>gc` makes a commit (and adds)
- `<leader>gm` merges the selected branch to chosen branches

### usage

only `<leader>gu`, `<leader>gc`, `<leader>gb` and `<leader>gp` will work without gui

when using `<leader>gs`, `<leader>ge`, `<leader>gs` and `<leader>gs` u must select the commit to perform it on

## customisation

this doesnt have much custumisation options except:

- width
- height
- glog(the graph)
- maximum_depth (how much commits does the thing process)

default options:

```lua
{
    'hakabol/git_intergration',
    config = function () require("git-nvim").setup({
        width = 150,
        height = 30,
        maximum_depth = 1000 --lower if too laggy
        glog = {
            "git",
            "log",
            "--graph",
            "--all",
            "--decorate",
            "--pretty=format:=%H",
        }
    }) end,
}
```
