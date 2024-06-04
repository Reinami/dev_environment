# install neovim

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage 
chmod u+x nvim.appimage 

./nvim.appimage 
mkdir -p /opt/nvim 
mv nvim.appimage /opt/nvim/nvim

if that doesn't work, do.

./nvim.appimage --appimage-extract 
./squashfs-root/AppRun --version

# Optional: exposing nvim globally. 
sudo mv squashfs-root / 
sudo ln -s /squashfs-root/AppRun /usr/bin/nvim 
nvim

# install packer

git clone --depth 1 https://github.com/wbthomason/packer.nvim\ ~/.local/share/nvim/site/pack/packer/start/packer.nvim # Make sure XDG_CONFIG_HOME is set properly to $HOME/.config/nvim if it is not, you may need to setup init.vim file in whatever directory it is set to set it as a possible runtime path.

# run ./main.sh -n

# run PackerSync

nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

# run ./main.sh -b

to setup bash
