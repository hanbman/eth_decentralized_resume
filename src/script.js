$(document).ready(() =>{

    $('#user').on('click', () => {
        $('#userExpand').toggle();
    });
    
    $('#admin').on('click', () => {
        $('#adminExpand').toggle();
    });
    
    $('#institution').on('click', () => {
        $('#institutionExpand').toggle();
    });

    $('#submit').on('click', () =>{
        $('.expand').hide();
        $('#thankyou').show();
        $('#enter').show();
    });
    
    $('#enter').on('click', () =>{
        $('#bottom').show();
        $('.container').hide();
        $('#thankyou').hide();
        $('#enter').hide();
        $('.header').hide();
    });

    $('#resumeQueue').on('click', () =>{
        $('#resumeQueueInfo').show();
        $('#queueSizeInfo').hide();
        $('#resumeSizeInfo').hide();
        $('#approveInfo').hide();
    });

    $('#queueSize').on('click', () =>{
        $('#queueSizeInfo').show();
        $('#resumeQueueInfo').hide();
        $('#resumeSizeInfo').hide();
        $('#approveInfo').hide();
    });

    $('#resumeSize').on('click', () =>{
        $('#resumeSizeInfo').show();
        $('#resumeQueueInfo').hide();
        $('#approveInfo').hide();
        $('#queueSizeInfo').hide();
    });

    $('#approve').on('click', () =>{
        $('#approveInfo').show();
        $('#resumeQueueInfo').hide();
        $('#queueSizeInfo').hide();
        $('#resumeSizeInfo').hide();
    });
})

