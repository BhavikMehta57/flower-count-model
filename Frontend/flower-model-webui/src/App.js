import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Route, Routes, Navigate } from 'react-router-dom';
import BatchProcess from './Components/BatchProcess';
import Login from './Components/Login';
import Register from './Components/Register';
import './App.css';

function App() {
    const [token, setToken] = useState(localStorage.getItem('token') || null);

    useEffect(() => {
        if (token) {
            localStorage.setItem('token', token);
        } else {
            localStorage.removeItem('token');
        }
    }, [token]);

    const handleLogout = () => {
        setToken(null);
        localStorage.clear(); // This will clear all localStorage data
        window.location.href = '/login'; // Redirect to login on logout
    };

    return (
        <Router>
            <div className="App">
                <div className="navbar">
                    <h1 style={{ margin: '0' }}>Flower Count Model App</h1>
                    <div className='log-buttons'>{token ? (
                        <button className='logout-button' onClick={handleLogout}>Logout</button>
                    ) : (
                        <>
                            <button className='login-button' onClick={() => window.location.href = '/login'}>Login</button>
                            <button className='register-button' onClick={() => window.location.href = '/register'}>Register</button>
                        </>
                    )}</div>
                </div>
                <Routes>
                    <Route
                        path="/"
                        element={token ? <BatchProcess token={token} /> : <Navigate to="/login" replace />}
                    />
                    <Route
                        path="/login"
                        element={<Login setToken={setToken} />}
                    />
                    <Route
                        path="/register"
                        element={<Register setToken={setToken} />}
                    />
                </Routes>
            </div>
        </Router>
    );
}

export default App;
