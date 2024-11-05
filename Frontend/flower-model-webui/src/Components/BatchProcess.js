import React, { useState, useEffect, useRef, useCallback } from 'react';
import axios from 'axios';
import DataTable from './DataTable';
import '../App.css';

const BatchProcess = ({ token }) => {
    const [taskId, setTaskId] = useState(localStorage.getItem('taskId') || null);
    const [loading, setLoading] = useState(false);
    const [status, setStatus] = useState(localStorage.getItem('status') || '');
    const [imagesProcessed, setImagesProcessed] = useState(Number(localStorage.getItem('imagesProcessed')) || 0);
    const [totalImages, setTotalImages] = useState(Number(localStorage.getItem('totalImages')) || 0);
    const [results, setResults] = useState(JSON.parse(localStorage.getItem('results') || '[{}]'));
    const pollingTimeout = useRef(null);
    const [imageUrls, setImageUrls] = useState([]);

    // Save state to localStorage on each change
    useEffect(() => {
        if (taskId) localStorage.setItem('taskId', taskId);
    }, [taskId]);

    useEffect(() => {
        localStorage.setItem('status', status);
    }, [status]);

    useEffect(() => {
        localStorage.setItem('imagesProcessed', imagesProcessed);
    }, [imagesProcessed]);

    useEffect(() => {
        localStorage.setItem('totalImages', totalImages);
    }, [totalImages]);

    useEffect(() => {
        localStorage.setItem('results', JSON.stringify(results));
    }, [results]);

    const handleProcessImages = async () => {
        setLoading(true);
        try {
            const response = await axios.post(
                'http://localhost:8000/process-images/',
                {},
                {
                    headers: {
                        'Authorization': `Bearer ${token}`,
                    },
                }
            );
            if (response.data && response.data.task_id) {
                setTaskId(response.data.task_id);
                fetchStatus(response.data.task_id);
            } else {
                console.error('No task ID returned from API.');
            }
        } catch (error) {
            console.error('Error processing images:', error);
            setLoading(false);
        }
    };

    const fetchStatus = useCallback (async (taskId) => {
        setLoading(true);
        try {
            const response = await axios.get(`http://localhost:8000/result/${taskId}`, {
                headers: {
                    'Authorization': `Bearer ${token}`,
                },
            });
            const data = response.data;

            setStatus(data.status);
            setImagesProcessed(data.images_processed);
            setTotalImages(data.total_images);
            setResults(data.result);

            if (data.status === 'Completed') {
                setResults(data.result);
                setLoading(false);
                clearTimeout(pollingTimeout.current); // Stop polling when complete
            } else {
                pollingTimeout.current = setTimeout(() => fetchStatus(taskId), 5000);
            }
        } catch (error) {
            console.error('Error fetching task status:', error);
            setLoading(false);
            clearTimeout(pollingTimeout.current); // Stop polling on error
        }
    }, [token]);

    useEffect(() => {

        const fetchImages = async () => {
            try {
                const response = await axios.get(`http://localhost:8000/get-dataset/`, {
                    headers: {
                        'Authorization': `Bearer ${token}`,
                    },
                });
                const data = response.data;
                setImageUrls(data.images);
            } catch (error) {
                console.error('Error fetching images:', error);
            }
        };
    
        fetchImages();

        if (taskId) {
            fetchStatus(taskId); // Start polling if taskId is already set
        }
        return () => {
            // Clear polling on component unmount
            if (pollingTimeout.current) clearTimeout(pollingTimeout.current);
        };
    }, [fetchStatus, taskId, token]);

    return (
        <div className='task-container'>
            <div className="task-details">
                <div className="task-header">
                    <span>Flower Count Dataset</span>
                    <button className="task-button" onClick={handleProcessImages} disabled={loading}>
                        {loading ? 'Processing...' : 'Start Flower Count'}
                    </button>
                </div>
                <div className="image-grid">
                    {imageUrls.map((url, index) => (
                        <img
                            key={index}
                            src={`http://localhost:8000/images/${url}`}
                            alt={`url`}
                            className="grid-image"
                        />
                    ))}
                </div>
                <div className='task-sub-details'>
                    {taskId && (
                        <div className="task-info">
                            <strong>Task ID:</strong> {taskId}
                        </div>
                    )}
                    {taskId && (
                        <div>
                            <strong>Task Status:</strong> {status}
                        </div>
                    )}
                </div>
            </div>
            {taskId && (
                <div className="loader">
                    <strong>Images Processed:</strong> {imagesProcessed} / {totalImages}
                    <div className="progress-bar">
                        <div
                            className="progress"
                            style={{
                                width: `${(imagesProcessed / totalImages) * 100}%`,
                            }}
                        ></div>
                    </div>
                </div>
            )}
            {(status === 'Processing' || status === 'Completed') && imagesProcessed > 0 && (
                <DataTable rows={results} />
            )}
        </div>
    );
};

export default BatchProcess;
