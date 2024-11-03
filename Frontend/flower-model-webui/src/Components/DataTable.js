import React, { useState } from 'react';
import './DataTable.css';

const DataTable = ({ rows }) => {
  const [rowsPerPage, setRowsPerPage] = useState(10); 
  const [currentPage, setCurrentPage] = useState(1);

  const totalPages = Math.ceil(rows.length / rowsPerPage);
  
  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(Number(event.target.value));
    setCurrentPage(1); 
  };

  const handlePageChange = (page) => {
    setCurrentPage(page);
  };

  const exportAllData = () => {
    const csvContent = generateCSVContent(rows);
    downloadCSV(csvContent, 'all_data.csv');
  };

  const generateCSVContent = (data) => {
    const headers = Object.keys(data[0]);
    const rows = data.map(row => headers.map(header => `"${row[header]}"`).join(','));
    return [headers.join(','), ...rows].join('\n');
  };

  const downloadCSV = (content, filename) => {
    const blob = new Blob([content], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.setAttribute('download', filename);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const indexOfLastRow = currentPage * rowsPerPage;
  const indexOfFirstRow = indexOfLastRow - rowsPerPage;
  const currentRows = rows.slice(indexOfFirstRow, indexOfLastRow);

  return (
    <div className="data-table">
      <div className="header">
        <div className="table-title">Table</div>
        <div className="export-buttons">
          <button onClick={exportAllData}>Export All Data</button>
        </div>
      </div>
      
      <div className="rows-per-page">
        <label>Rows per page:</label>
        <select value={rowsPerPage} onChange={handleChangeRowsPerPage}>
          <option value={5}>5</option>
          <option value={10}>10</option>
          <option value={25}>25</option>
          <option value={50}>50</option>
        </select>
      </div>

      <table>
        <thead>
          <tr>
            <th>Image</th>
            <th>File Name</th>
            <th>Count</th>
          </tr>
        </thead>
        <tbody>
          {currentRows.map((row, index) => (
            <tr key={index}>
              <td><img src={row.image} alt={row.image_name} width="100" /></td>
              <td>{row.image_name}</td>
              <td>{row.count}</td>
            </tr>
          ))}
        </tbody>
      </table>

      <div className="pagination">
        {Array.from({ length: totalPages }, (_, index) => (
          <button
            key={index + 1}
            onClick={() => handlePageChange(index + 1)}
            disabled={currentPage === index + 1}
          >
            {index + 1}
          </button>
        ))}
      </div>
    </div>
  );
};

export default DataTable;
