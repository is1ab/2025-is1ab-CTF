import sys
import redis
import json
import pycurl
import base64
import uuid
from io import BytesIO
from flask import Flask, request, Response, session
from models import *

app = Flask(__name__)
app.secret_key = b'\x53\x3b\xce\xf1\x23\x2d\xab\xc2\x11\x23'

@app.route("/api/")
def ping():
    version = "{}.{}".format(sys.version_info.major, sys.version_info.minor)
    message = "Flask running on Python {}".format(
        version
        )
    return message

@app.route("/api/login", methods=['GET'])
def login():
    if 'id' not in session:
        session['id'] = str(uuid.uuid4())
        return ''
    else:
        return json.dumps({'msg':'Already logged in'})

@app.route("/api/docs", methods=['GET', 'POST'])
def manageDocs():
    if 'id' not in session:
        return json.dumps({'msg':'Invalid session'})

    if request.method == 'GET':
        docs = Document.list(session['id'])
        return json.dumps(docs)
    elif request.method == 'POST':
        newDoc = Document(request.form['url'], session['id'])
        return json.dumps({'msg':'OK', 'url':'/api/download?id=' + newDoc.fileid})

@app.route("/api/download", methods=['GET'])
def downloadFile():
    file_id = request.args.get('id','')
    server = request.args.get('server','')

    #for testing purposes only
    if request.remote_addr != '127.0.0.1':
        server = 'http://127.0.0.1'
    
    if file_id!='':
        filename = str(int(file_id)) + '.pdf'

        response_buf = BytesIO()
        crl = pycurl.Curl()
        crl.setopt(crl.URL, server + '/api/file?filename=' + filename)
        crl.setopt(crl.WRITEDATA, response_buf)
        crl.perform()
        crl.close()
        file_data = json.loads(response_buf.getvalue().decode('utf8')).get('file','')
        file_data = base64.b64decode(file_data)

        resp = Response(file_data)
        resp.headers['Content-Type'] = 'text/html'
        return resp
    else:
        return json.dumps({'msg':'Invalid file id'})


# The file storage will soon be migrated to a different server
@app.route("/api/file", methods=['GET'])
def getFile():
    if request.remote_addr != '127.0.0.1':
        return json.dumps({'msg':'Remote access disallowed'})
    else:
        PDF_DIR = '/app/web/pdfs/'
        filename = PDF_DIR + request.args.get('filename', '')
        try:
            data = open(filename, 'rb').read()
            data = base64.b64encode(data).decode('utf8')
            return json.dumps({'msg':'ok', 'file':data})
        except:
            return json.dumps({'msg':'Invalid filename'})

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True, port=8001)
