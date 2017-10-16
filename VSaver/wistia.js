function vsaverGetURL() {
    let jsonp = vsaver.json;
    let assets = jsonp.media.assets
    let videoUrls = {}
    
    assets.forEach(function(item) {
                   let container = item.container || ""
                   videoUrls[item.display_name + container] = item.url
                   })
    
    let valid_slugs = ["1080pm3u8", "1080pmp4", "Original file", "720pm3u8", "720pmp4"]
    
    let url = ""
    for (let i in valid_slugs) {
        let slug = valid_slugs[i]
        if (videoUrls[slug] != null) {
            url = videoUrls[slug]
            break
        }
    }
    
    return url
}

function vsaverGetTitle() {
    let element = document.querySelector('#title h1')
    
    if (element != null) {
        return element.innerText
    }
    
    return document.title
}
