import { useEffect, useState } from "react";

function App() {
  const [backendStatus, setBackendStatus] = useState("Checking...");
  const [applicationInfo, setApplicationInfo] = useState(null);

  const backendUrl =
    import.meta.env.VITE_BACKEND_URL || "http://localhost:5000";

  useEffect(() => {
    fetch(`${backendUrl}/health`)
      .then((response) => {
        if (!response.ok) {
          throw new Error("Backend unavailable");
        }
        return response.json();
      })
      .then(() => {
        setBackendStatus("Healthy");
      })
      .catch(() => {
        setBackendStatus("Unavailable");
      });

    fetch(`${backendUrl}/api/info`)
      .then((response) => response.json())
      .then((data) => {
        setApplicationInfo(data);
      })
      .catch(() => {
        setApplicationInfo(null);
      });
  }, [backendUrl]);

  return (
    <div className="app">
      <div className="container">
        <h1>DevSecOps EKS Application</h1>

        <p className="subtitle">
          End-to-End DevSecOps & GitOps Project
        </p>

        <div className="card">
          <h2>Application Status</h2>

          <p>
            Backend:
            <strong> {backendStatus}</strong>
          </p>

          {applicationInfo && (
            <>
              <p>
                Environment:
                <strong> {applicationInfo.environment}</strong>
              </p>

              <p>
                Redis Visits:
                <strong> {applicationInfo.visits}</strong>
              </p>
            </>
          )}
        </div>

        <div className="architecture">
          <span>React</span>
          <span>→</span>
          <span>Node.js</span>
          <span>→</span>
          <span>Redis</span>
        </div>
      </div>
    </div>
  );
}

export default App;
