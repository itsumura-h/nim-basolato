import basolato/view

proc headHtml*():string = tmpli html"""
$(csrf_token())
<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css">
<link href='//fonts.googleapis.com/css?family=Lobster&subset=latin,latin-ext' rel='stylesheet' type='text/css'>
<link data-turbolinks-track="true" href="/assets/stylesheets/custom.css" media="all" rel="stylesheet" />
<script data-turbolinks-track="true" src="/assets/stylesheets/custom.js"></script>
"""
