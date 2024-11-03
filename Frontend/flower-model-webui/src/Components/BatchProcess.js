import React, { useState } from 'react';
import axios from 'axios';
import DataTable from './DataTable';
import '../App.css';

const BatchProcess = () => {
    const [taskId, setTaskId] = useState(null);
    const [loading, setLoading] = useState(false);
    const [status, setStatus] = useState('');
    const [imagesProcessed, setImagesProcessed] = useState(0);
    const [totalImages, setTotalImages] = useState(0);
    const [results, setResults] = useState([{}]);

    const handleProcessImages = async () => {
        setLoading(true);
        try {
            const response = await axios.post('http://localhost:8000/process-images/');
            console.log('Process Images Response: ', response.data); // Debugging line
            if (response.data && response.data.task_id) {
                console.log('Task ID:', response.data.task_id); // Debugging line
                setTaskId(response.data.task_id);
                console.log(taskId)
                fetchStatus(response.data.task_id)
            } else {
                console.error('No task ID returned from API.');
            }
        } catch (error) {
            console.error('Error processing images:', error);
        }
    };

    const fetchStatus = async (taskId) => {
        try {
            const response = await axios.get(`http://localhost:8000/result/${taskId}`);
            const data = response.data;
            console.log('Task Status for ', taskId, ':', response.data); // Debugging line

            setStatus(data.status);
            setImagesProcessed(data.images_processed);
            setTotalImages(data.total_images);
            setResults(data.result)

            if (data.status === 'Completed') {
                setResults(data.result);
                console.log('Results: ', results)
                setLoading(false);
            } else {
                // Call fetchStatus again in 5 seconds without immediate execution
                setTimeout(() => fetchStatus(taskId), 5000);
            }
        } catch (error) {
            console.error('Error fetching task status:', error);
            clearTimeout(fetchStatus); // Stop polling on error
        }
    };

    return (
        <div>
            <div className="task-details">
                {taskId !== null && (<div className="task-info">
                    <strong>Task ID:</strong> {taskId}
                </div>)}
                {taskId !== null && (<div>
                    <strong>Task Status:</strong> {status}
                </div>)}
                <button className="task-button" onClick={handleProcessImages} disabled={loading}>
                    {loading ? 'Processing...' : 'Start Flower Count'}
                </button>
            </div>
            {/* Loader and Progress */}
            {taskId !== null && (<div className="loader">
                <strong>Images Processed:</strong> {imagesProcessed} / {totalImages}
                <div className="progress-bar">
                <div
                    className="progress"
                    style={{
                    width: `${(imagesProcessed / totalImages) * 100}%`,
                    }}
                ></div>
                </div>
            </div>)}
            {(status === 'Processing' || status === 'Completed') && imagesProcessed > 0 && (
                    <DataTable rows={results} />
                )}
        </div>
        
    );
};

export default BatchProcess;
