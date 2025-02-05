const http = require('node:http')
const fs= require('fs')

const data = fs.readFileSync('dashboard.html', 'utf8')

const userMap = {
  '1c7b8d1d-87ac-4260-87ca-a21477d275da': 'Ronnie',
}

function redirectToLogin(res) {
    res.statusCode = 302
    res.setHeader('Location', '/auth/login')
    res.end()
    return
}

http.createServer((req, res) => {
  const uidHeader = req.headers['x-jwt-subject-id']
  console.log(`processing req with uid = ${uidHeader}`)

  let uid;
  try {
    uid = JSON.parse(uidHeader)
  } catch {
    return redirectToLogin(res)
  }

  if (!uid) return redirectToLogin(res);

  res.setHeader('Content-Type', 'text/html')
  res.write(data
    .replace('$$$USER$$$', userMap[uid])
    .replace('$$$PAR$$$', uid in userMap ? `<p>You have accessed the repository dashboard. The flag is ${process.env.FLAG}</p>` : '')
  );
  res.end()
}).listen(80)
