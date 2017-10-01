---
---

$(document).ready ->
    $.get 'https://api.github.com/users/evanlindsey/repos', (data) ->
        for d in data
            $('.project-content').append('
                <a class="page-link" href="' + d.html_url + '">' + d.name + '</a>
            ');
