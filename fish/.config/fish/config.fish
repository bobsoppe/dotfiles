## Fisher
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end


## Environment

# paths
for index in (seq (count $PATH))
	if test $PATH[$index] = "/usr/sbin"
		set foundIndex $index
	end
end
set -x PATH $PATH[1..(expr $foundIndex - 1)] /usr/local/sbin $PATH[$foundIndex..(count $PATH)]
set -e foundIndex

for index in (seq (count $PATH))
	if test $PATH[$index] = "/usr/local/bin"
		set foundIndex $index
	end
end
set -x PATH $PATH[1..(expr $foundIndex - 1)] $HOME/.local/bin $PATH[$foundIndex..(count $PATH)]
set -e foundIndex

for index in (seq (count $PATH))
	if test $PATH[$index] = "/usr/local/bin"
		set foundIndex $index
	end
end
set -x PATH $PATH[1..(expr $foundIndex - 1)] /usr/local/opt/python/libexec/bin $PATH[$foundIndex..(count $PATH)]
set -e foundIndex

# language
set -x LANGUAGE en_US.UTF-8
set -x LANG $LANGUAGE
set -x LC_ALL $LANGUAGE
set -x LC_CTYPE $LANGUAGE

# editor
set -x EDITOR micro
set -x CVSEDITOR $EDITOR
set -x SVN_EDITOR $EDITOR
set -x GIT_EDITOR $EDITOR

# pager
#set -x LESS $LESS -FRK
set -x PAGER most
set -x MANPAGER $PAGER

set -x AWS_PAGER less -FRKX
set -x GIT_PAGER less -FKRX

# gpg
set -x GPG_TTY "tty"

# wine
set -x WINE /usr/local/bin/wine32on64

# fish
set -x fish_color_normal normal						# the default color
set -x fish_color_command --bold blue				# the color for commands
set -x fish_color_quote green						# the color for quoted blocks of text
set -x fish_color_redirection normal				# the color for IO redirections
set -x fish_color_end --bold normal					# the color for process separators like ';' and '&'
set -x fish_color_error red							# the color used to highlight potential errors
set -x fish_color_param normal						# the color for regular command parameters
set -x fish_color_comment brblack					# the color used for code comments
set -x fish_color_match --underline					# the color used to highlight matching parenthesis
set -x fish_color_search_match --background=blue	# used to highlight history search matches and the selected pager item (must be a background)
set -x fish_color_operator --bold normal			# the color for parameter expansion operators like '*' and '~'
set -x fish_color_escape yellow						# the color used to highlight character escapes like '\n' and '\x70'
set -x fish_color_autosuggestion brblack			# the color used for autosuggestions
set -x fish_color_cancel --bold red					# the color for the '^C' indicator on a canceled command

set -x fish_pager_color_prefix --bold normal		# the color of the prefix string, i.e. the string that is to be completed
set -x fish_pager_color_completion normal			# the color of the completion itself
set -x fish_pager_color_description brblack			# the color of the completion description
set -x fish_pager_color_progress --bold brblack		# the color of the progress bar at the bottom left corner
set -x fish_pager_color_secondary black				# the background color of the every second completion

set -x fish_greeting ''

# ls
set -x LS_COLORS 'no=00:rs=0:fi=00:di=01;34:ln=36:mh=04;36:pi=04;01;36:so=04;33:do=04;01;36:bd=01;33:cd=33:or=31:mi=01;37;41:ex=01;36:su=01;04;37:sg=01;04;37:ca=01;37:tw=01;37;44:ow=01;04;34:st=04;37;44:*.7z=01;32:*.ace=01;32:*.alz=01;32:*.arc=01;32:*.arj=01;32:*.bz=01;32:*.bz2=01;32:*.cab=01;32:*.cpio=01;32:*.deb=01;32:*.dz=01;32:*.ear=01;32:*.gz=01;32:*.jar=01;32:*.lha=01;32:*.lrz=01;32:*.lz=01;32:*.lz4=01;32:*.lzh=01;32:*.lzma=01;32:*.lzo=01;32:*.rar=01;32:*.rpm=01;32:*.rz=01;32:*.sar=01;32:*.t7z=01;32:*.tar=01;32:*.taz=01;32:*.tbz=01;32:*.tbz2=01;32:*.tgz=01;32:*.tlz=01;32:*.txz=01;32:*.tz=01;32:*.tzo=01;32:*.tzst=01;32:*.war=01;32:*.xz=01;32:*.z=01;32:*.Z=01;32:*.zip=01;32:*.zoo=01;32:*.zst=01;32:*.aac=32:*.au=32:*.flac=32:*.m4a=32:*.mid=32:*.midi=32:*.mka=32:*.mp3=32:*.mpa=32:*.mpeg=32:*.mpg=32:*.ogg=32:*.opus=32:*.ra=32:*.wav=32:*.3des=01;35:*.aes=01;35:*.gpg=01;35:*.pgp=01;35:*.doc=32:*.docx=32:*.dot=32:*.odg=32:*.odp=32:*.ods=32:*.odt=32:*.otg=32:*.otp=32:*.ots=32:*.ott=32:*.pdf=32:*.ppt=32:*.pptx=32:*.xls=32:*.xlsx=32:*.app=01;36:*.bat=01;36:*.btm=01;36:*.cmd=01;36:*.com=01;36:*.exe=01;36:*.reg=01;36:*~=02;37:*.bak=02;37:*.BAK=02;37:*.log=02;37:*.log=02;37:*.old=02;37:*.OLD=02;37:*.orig=02;37:*.ORIG=02;37:*.swo=02;37:*.swp=02;37:*.bmp=32:*.cgm=32:*.dl=32:*.dvi=32:*.emf=32:*.eps=32:*.gif=32:*.jpeg=32:*.jpg=32:*.JPG=32:*.mng=32:*.pbm=32:*.pcx=32:*.pgm=32:*.png=32:*.PNG=32:*.ppm=32:*.pps=32:*.ppsx=32:*.ps=32:*.svg=32:*.svgz=32:*.tga=32:*.tif=32:*.tiff=32:*.xbm=32:*.xcf=32:*.xpm=32:*.xwd=32:*.xwd=32:*.yuv=32:*.anx=32:*.asf=32:*.avi=32:*.axv=32:*.flc=32:*.fli=32:*.flv=32:*.gl=32:*.m2v=32:*.m4v=32:*.mkv=32:*.mov=32:*.MOV=32:*.mp4=32:*.mpeg=32:*.mpg=32:*.nuv=32:*.ogm=32:*.ogv=32:*.ogx=32:*.qt=32:*.rm=32:*.rmvb=32:*.swf=32:*.vob=32:*.webm=32:*.wmv=32:'

# homebrew
set -x HOMEBREW_NO_ANALYTICS 1

# pipenv
set -x PIPENV_IGNORE_VIRTUALENVS -1



## Aliases
alias ls 'ls -laG'

