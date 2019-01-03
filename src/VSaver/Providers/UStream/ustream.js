function vsaverMain() {
    document.querySelector('.playScreen').click()
    
    let interval = null;
    let findVideo = () => {
        let video = document.querySelector('video');
        if (video && video.src && video.src.indexOf('http') === 0) {
            let title = window.title
            let titleElement = document.querySelector('.playScreen .title')
            if (titleElement && titleElement.innerText) {
                title = titleElement.innerText
            }
            vsaverCompletion(video.src, title)
            clearInterval(interval)
        }
    }
    interval = setInterval(findVideo, 500)
    findVideo()
}
