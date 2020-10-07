//
//  HTMLSources.swift
//  iframe-sandbox-test
//
//  Created by Alastair Coote on 10/7/20.
//

import Foundation

enum HTMLSource : String {
    case wrapperPage = """
        <!DOCTYPE>
        <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1">
            </head>
            <body>
                <p>This is some content.</p>
                <iframe src="iframe.html" sandbox="allow-scripts allow-top-navigation-by-user-activation" style="height: 500px"></iframe>
            </body>
        </html>

    """


    case iframePage = """
        <!DOCTYPE>
        <html>
            <body>
                <p>This page is going to try to change the page location every 500ms, but you
                won't ever see anything because the iframe has a sandbox attribute and doesn't
                specify "allow-top-navigation".</p>
                <p>But it DOES have "allow-top-navigation-by-user-activation", so you can activate it:</p>
                <button id='immediate'>Try to change URL as part of user event cycle</button>
            <body>
            <script>
                function doNavigation() {
                    window.top.location = 'https://www.example.com';
                }

                setInterval(doNavigation, 500);
                document.getElementById('immediate').addEventListener('click', doNavigation);
            </script>
        </html>

    """
}
