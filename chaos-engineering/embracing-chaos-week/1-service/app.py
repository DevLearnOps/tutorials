from starlette.applications import Starlette
from starlette.responses import Response
from starlette.routing import Route


async def homepage(request):
    html = """<html>
    <body> <h1>Let's do some chaos!</h1> </body>
    </html>"""
    return Response(html, media_type="text/html")


app = Starlette(
    debug=True,
    routes=[
        Route("/", homepage),
    ],
)
