import axios from 'axios'

class CachedFetcher {
  constructor(apiUrl) {
    this.apiUrl = apiUrl
    this.cacheStore = {}
  }

  fetch(id) {
    return this._cachedOrFetch(id)
  }

  _cachedOrFetch(id) {
    const url = this.apiUrl(id)
    const { cacheStore } = this
    const cached = this.cacheStore[url]

    if (cached) {
      return Promise.resolve(cached)
    }

    return axios.get(url).
      then((response) => {
        cacheStore[url] = response.data
        return response.data
      }).
      catch((err) => console.log(err)) // eslint-disable-line no-console
  }
}

export default CachedFetcher
