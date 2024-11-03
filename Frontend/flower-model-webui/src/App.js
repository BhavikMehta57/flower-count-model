// import React, { useState } from 'react';
import BatchProcess from './Components/BatchProcess';
// import TaskStatus from './Components/TaskStatus';
import './App.css';

function App() {

    return (
        <div className="App">
            <div className="navbar">
                <h1 style={{ margin: '0' }}>Flower Count Model App</h1>
            </div>
            <BatchProcess />
        </div>
    );
}

export default App;
