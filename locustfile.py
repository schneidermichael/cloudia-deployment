from locust import task, FastHttpUser

class LoadTest(FastHttpUser):
    @task
    def workload(self):
        response = self.client.get("/")