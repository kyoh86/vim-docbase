command! DocBaseTeams :call docbase#list_teams()
command! -nargs=? DocBaseList :call docbase#list_posts(<args>)
command! -nargs=? DocBaseGroups :call docbase#list_groups(<args>)
