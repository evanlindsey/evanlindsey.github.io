---
---

$(document).ready ->
    $.get 'https://api.github.com/users/evanlindsey/repos', (data) ->
        for d in data
            $('#projects').append('
            <div class="media text-muted pt-3">
                <div class="media-body pb-3 mb-0 small lh-125 border-bottom border-gray">
                    <div class="d-flex justify-content-between align-items-center w-100">
                        <a class="page-link" href="' + d.html_url + '">' + d.name + '</a>
                    </div>
                    <div class="desc">' + d.description + '</div>
                </div>
            </div>
        ');
