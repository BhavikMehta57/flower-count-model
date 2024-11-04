import React, { useState } from 'react';
import axios from 'axios';
import '../App.css';

const Register = ({ setToken }) => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [errorMessage, setErrorMessage] = useState('');
    const [successMessage, setSuccessMessage] = useState('');

    const handleSubmit = async (event) => {
        event.preventDefault();
        try {
            const response = await axios.post('http://localhost:8000/register', {
                username,
                password,
            });
            
            if (response.status === 200) {
                setSuccessMessage('Registration successful! Please log in.');
                setErrorMessage('');
            }

        } catch (error) {
            setErrorMessage('Registration failed');
            console.error('Registration error:', error);
        }
    };

    return (
        <div className="register-form">
            <h2>Register</h2>
            <form onSubmit={handleSubmit} className="form-container">
            <div className='input-field'>
                    <label className="input-label">Username:</label>
                    <input
                        className="input-element"
                        type="text"
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                        required
                    />
                </div>
                <div className='input-field'>
                    <label className="input-label">Password:</label>
                    <input
                        className="input-element"
                        type="password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        required
                    />
                </div>
                <button className='register-button' type="submit">Register</button>
                {errorMessage && <p className="error">{errorMessage}</p>}
                {successMessage && <p className="success">{successMessage}</p>}
            </form>
        </div>
    );
};

export default Register;
