#!/usr/bin/env python3
import http.server, socket

PORT = 8888
APK = r'Z:\vibe_coding\shiling-fruit\build\app\outputs\flutter-apk\app-debug.apk'
HTML = '''<html><head><meta charset="utf-8"><title>ShiLing Fruit</title>
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>
body{font-family:sans-serif;text-align:center;padding:40px;background:#f5f5f5}
.card{background:white;border-radius:16px;padding:32px;max-width:400px;margin:0 auto;box-shadow:0 2px 12px rgba(0,0,0,0.1)}
.btn{display:block;background:#4CAF50;color:white;padding:16px;border-radius:12px;text-decoration:none;font-size:18px;font-weight:bold;margin-top:16px}
</style></head><body>
<div class="card">
<h1>&#x1F347; ShiLing Fruit</h1>
<p style="color:#666">Download APK and install on your phone</p>
<a class="btn" href="/apk" download>&#x1F4E5; Download APK (186MB)</a>
</div></body></html>'''

class H(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(HTML.encode())
        elif self.path == '/apk':
            self.send_response(200)
            self.send_header('Content-type', 'application/vnd.android.package-archive')
            self.send_header('Content-Disposition', 'attachment')
            self.end_headers()
            with open(APK, 'rb') as f:
                self.wfile.write(f.read())
        else:
            self.send_error(404)

if __name__ == '__main__':
    ip = socket.gethostbyname(socket.gethostname())
    print(f'http://{ip}:{PORT}')
    print(f'http://localhost:{PORT}')
    http.server.HTTPServer(('0.0.0.0', PORT), H).serve_forever()