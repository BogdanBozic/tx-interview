from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def hello_world():
    return "Hello Goldbach from BastovanSurcinski"

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=11271)
