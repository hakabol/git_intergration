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

only `<leader>gu`, `<leader>gc`, `<leader>gu` and `<leader>gp` will work without gui

when using `<leader>gs`, `<leader>ge`, `<leader>gs` and `<leader>gs` u must select the commit to perform it on
