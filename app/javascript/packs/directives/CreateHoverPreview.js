function createPreview(el, value, fetcher) {
  const previewWrapper = document.createElement('div')
  const previewContent = document.createElement('span')
  const recordId = value

  previewWrapper.classList.add('vue-hover-preview-directive')
  previewContent.innerHTML = `Loading (ID ${recordId})...`
  previewWrapper.appendChild(previewContent)

  const body = document.getElementsByTagName('body')[0]
  body.appendChild(previewWrapper)

  el.onmouseover = function() {
    fetcher.fetch(recordId).
      then((data) => { previewContent.innerHTML = data.preview }).
      then((_data) => { window.AntCat.CreateCopyButtons(previewContent) })

    const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop
    previewWrapper.style.display = 'inline-block'

    previewWrapper.style.left = `${el.getBoundingClientRect().left +
      el.getBoundingClientRect().width + scrollLeft}px`

    previewWrapper.style.top = `${el.getBoundingClientRect().top -
      previewWrapper.getBoundingClientRect().height / 2 +
      el.getBoundingClientRect().height / 2 + scrollTop}px`
  }

  el.onmouseleave = function() {
    previewWrapper.style.display = 'none'
  }

  previewWrapper.onmouseover = function() {
    previewWrapper.style.display = 'inline-block'
  }

  previewWrapper.onmouseleave = function() {
    previewWrapper.style.display = 'none'
  }
}

const CreateHoverPreview = function(fetcher) {
  return {
    bind(el, binding) {
      if (binding.value && binding.value !== '') {
        createPreview(el, binding.value, fetcher)
      }
    },
  }
}

export default CreateHoverPreview
