#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

get_tmux_option() {
  local option=$1
  local default_value=$2
  local option_value=$(tmux show-option -gqv "$option")
  if [ -z $option_value ]; then
    echo $default_value
  else
    echo $option_value
  fi
}

main()
{
  # set current directory variable
  current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # set configuration option variables
  show_powerline=$(get_tmux_option "@darkly-show-powerline" true)
  show_left_icon=$(get_tmux_option "@darkly-show-left-icon" lambda)
  show_left_sep=$(get_tmux_option "@darkly-show-left-sep" )
  show_right_sep=$(get_tmux_option "@darkly-show-right-sep" )

  # darkly Color Pallette
  white='#f8f8f2'
  gray='#444444'
  dark_gray='#323232'
  green='#4bc98a'
  yellow='#f1fa8c'


  # Handle left icon configuration
  case $show_left_icon in
      lambda)
          left_icon="Ⲗ ";;
      session)
          left_icon="#S ";;
      window)
	  left_icon="#W ";;
      *)
          left_icon=$show_left_icon;;
  esac

  # Handle powerline option
  if $show_powerline; then
      right_sep="$show_right_sep"
      left_sep="$show_left_sep"
  fi

  # set length
  tmux set-option -g status-left-length 100
  tmux set-option -g status-right-length 100

  tmux set-option -g pane-active-border-style "fg=${green}"
  tmux set-option -g pane-border-style "fg=${gray}"

  # message styling
  tmux set-option -g message-style "bg=${gray},fg=${white}"

  # status bar
  tmux set-option -g status-style "bg=${dark_gray},fg=${white}"

  # Powerline Configuration
  if $show_powerline; then

    tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${yellow}],} ${left_icon} #[fg=${green},bg=${dark_gray}]#{?client_prefix,#[fg=${yellow}],}${left_sep}"
    tmux set-option -g  status-right ""
    powerbg=${dark_gray}
    tmux set-window-option -g window-status-current-format "#[fg=${dark_gray},bg=${green}]${left_sep}#[fg=${white},bg=${green}] #I #W${current_flags} #[fg=${green},bg=${dark_gray}]${left_sep}"

  # Non Powerline Configuration
  else
    tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${yellow}],} ${left_icon}"
    tmux set-option -g  status-right ""
    tmux set-window-option -g window-status-current-format "#[fg=${white},bg=${green}] #I #W${current_flags} "

  fi

  tmux set-window-option -g window-status-format "#[fg=${white}]#[bg=${dark_gray}] #I #W${flags}"
  tmux set-window-option -g window-status-activity-style "bold"
  tmux set-window-option -g window-status-bell-style "bold"
}

# run main function
main
