/* min version: 1.4.2 */

function vsaverGetURL() {
    let videoUrls = {};
    
    if (ytplayer.config.args.hlsvp != undefined) {
        return ytplayer.config.args.hlsvp
    }
    ytplayer.config.args.url_encoded_fmt_stream_map.split(',').forEach(function (item) {
                                                                       let obj = {};
                                                                       
                                                                       item.split('&').forEach(function (param) {
                                                                                               param = param.split('=');
                                                                                               obj[param[0]] = decodeURIComponent(param[1]);
                                                                                               });
                                                                       videoUrls[obj.itag] = obj;
                                                                       
                                                                       });
    let valid_itags = ["95", "299", "266", "137", "22", "136", "135", "134", "18", "133", "160"]

    let url = ""
    for (let i in valid_itags) {
        let itag = valid_itags[i]
        if (videoUrls[itag] != null) {
            url = videoUrls[itag].url
            break
        }
    }

    return url
}

function vsaverGetTitle() {
    return ytplayer.config.args.title || document.title
}
