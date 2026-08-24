# dotfiles
<img width="1214" height="1002" alt="kitty with fastfetches shown" src="https://raw.githubusercontent.com/jitterdev/dotfiles/master/preview/fetches.png" />

## install
```
bash -c "$(curl -fsSL "https://raw.githubusercontent.com/jitterdev/dotfiles/master/install.sh?$(date +%s)")"
```
⚠️ please note that this will likely not give you the result you want or expect if your user is not named "jitter". as i designed this to be installed by me (you know, because they're *my* dotfiles)

⚠️ you will likely be better off cherry-picking what you want from the files rather than trying to download everything i use as there's a high likelihood you will just end up with things that serve no purpose to you or breaking something.

install won't work if you don't have pacman (so you need an arch-based distro, generally), and if you don't have an AUR helper installed, paru will be installed automatically

⚠️ if your run fails, you'll need to do `rm -rf ~/.dotfiles` and `sudo chown -R $(id -un): $(id -gn) ~/.dotfiles-backup` if it exists before you re-run!

## features
- **a nice prompt**: git aware, two-line fish prompt with transience and timestamps
<img width="1086" height="67" src="https://raw.githubusercontent.com/jitterdev/dotfiles/master/preview/prompt.png" />

- **system-wide sane fish defaults**: bat (replacing cat for concatenation), moor (replacing less for paging)
- **utility aliases**: lots of them
<img width="500" height="100%" src="https://raw.githubusercontent.com/jitterdev/dotfiles/master/preview/aliases.png" />

* **forked plasma task switcher theme**: based on [Modern Informative](https://store.kde.org/p/2128868), adds an x to close applications and makes middle-clicking applications close them.
<img width="500" src="https://raw.githubusercontent.com/jitterdev/dotfiles/master/preview/task_switcher.gif" />

* **fzf improvements**: image (kitty's icat), video preview (ffmpegthumbnailer), pdf (pdftotext), and archive (atool) support
<img width="500" src="https://raw.githubusercontent.com/jitterdev/dotfiles/master/preview/fzf.gif" />

## faq
> "why do you use both `/etc/fish` and `$HOME/.config/fish`?"
* if i'm in a root shell via `sudo -i` or `sudo -s`  i would prefer to be using my same defaults for my user. this method also applies defaults like the prompt to all users by default but still allows for them to overwrite if they so choose. plus, if you need, want, or prefer bash in a root shell you can simply do `bash`

> "why is your dotfiles work-tree set to `/`?"
* i also save some system configurations and this git repository is structured to mirror my root filesystem

> "why don't you use stow/chezmoi/yadm/some other tool?"
* i don't like the symlink layout and i prefer the minimal level of just using a bare git repo
