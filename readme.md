## installation

Lazy

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
