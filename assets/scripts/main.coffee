---
---

$(document).ready ->
    $.get 'https://api.github.com/users/evanlindsey/repos', (data) ->
        for d in data
            name = d.name
            desc = d.description
            url = if d.homepage != "" then d.homepage else d.html_url
            $('#projects').append('
                <div class="media text-muted pt-3">
                    <div class="media-body pb-3 mb-0 small lh-125 border-bottom border-gray">
                        <div class="d-flex justify-content-between align-items-center w-100">
                            <a class="page-link" href="' + url + '">' + name + '</a>
                        </div>
                        <div class="desc">' + desc + '</div>
                    </div>
                </div>
            ');
