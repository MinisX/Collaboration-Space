import asyncio
from websockets import serve
import websockets

async def server(ws, path):
    async for msg in ws:
        msg = msg.decode('utf-8')
        print(f"Message from client: {msg}")
        await ws.send(f"Got your message: {msg}")

start_server = websockets.serve(server, "localhost", 3000)
print("Server started")
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()