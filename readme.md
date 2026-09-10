# Git intergration for nvim

## installation

For Lazy:

```lua
{
    'hakabol/git_intergration',
    config = function () require("git-nvim").setup() end,
}
```

## usage

Note: these instructions are with the default config of the plugin

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

this doesnt have much custumisation options except windth, height, and glog(the graph)

note glog doesnt support ansi yet

default options:

```lua
{
    'hakabol/git_intergration',
    config = function () require("git-nvim").setup({
        width = 150,
        height = 30,
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
