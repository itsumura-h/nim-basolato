import basolato/view


proc headView*(title:string):Component =
  tmpl"""
    <head>
      <meta name="viewport" content="width=device-width, newial-scale=1.0">
      <meta charset="utf-8" />
      <title>$(title)</title>
      <!-- Import Ionicon icons & Google Fonts our Bootstrap theme relies on -->
      <link
        href="//code.ionicframework.com/ionicons/2.0.1/css/ionicons.min.css"
        rel="stylesheet"
        type="text/css"
      />
      <link
        href="//fonts.googleapis.com/css?family=Titillium+Web:700|Source+Serif+Pro:400,700|Merriweather+Sans:400,700|Source+Sans+Pro:400,300,600,700,300italic,400italic,600italic,700italic"
        rel="stylesheet"
        type="text/css"
      />
      <!-- Import the custom Bootstrap 4 theme from our hosted CDN -->
      <link rel="stylesheet" href="/css/main.css" />

      <!-- htmx -->
      <script src="/js/htmx.js"></script>
      <!-- tagify -->
      <link rel="stylesheet" href="/css/tagify.css">
      <style>
        .tagify--outside{
          border: 0;
        }
  
        .tagify--outside .tagify__input{
          order: -1;
          flex: 100%;
          border: 1px solid var(--tags-border-color);
          margin-bottom: 1em;
          transition: .1s;
        }
  
        .tagify--outside .tagify__input:hover{ border-color:var(--tags-hover-border-color); }
        .tagify--outside.tagify--focus .tagify__input{
          transition:0s;
          border-color: var(--tags-focus-border-color);
        }
  
        .tagify__input { border-radius: 4px; margin: 0; padding: 10px 12px; }
      </style>
    </head>
  """
