function getCommonStatusBadge(status) {
    status = status || '';

    let badgeClass = 'bg-secondary';
    let textClass = '';
    let label = status || '--';

    switch (status) {
        case 'PENDING_OFFICER':
            badgeClass = 'bg-warning';
            textClass = 'text-dark';
            label = 'Pending Officer';
            break;

        case 'PENDING_REPORTING':
            badgeClass = 'bg-info';
            textClass = 'text-dark';
            label = 'Pending Reporting';
            break;

        case 'PENDING_REVIEWING':
            badgeClass = 'bg-warning';
            textClass = 'text-dark';
            label = 'Pending Reviewing';
            break;

        case 'PENDING_ACCEPTING':
            badgeClass = 'bg-info';
            textClass = 'text-dark';
            label = 'Pending Accepting';
            break;

        case 'APPROVED':
            badgeClass = 'bg-success';
            label = 'Approved';
            break;

        case 'REJECTED':
            badgeClass = 'bg-danger';
            label = 'Rejected';
            break;

        default:
            badgeClass = 'bg-secondary';
            label = status || '--';
            break;
    }

    return '<span class="badge ' + badgeClass + ' ' + textClass + '">' + label + '</span>';
}
