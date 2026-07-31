// ===== Lightbox - 点击缩略图在当前页面悬浮放大显示完整图片 =====

let lightboxOverlay = null;
let lightboxImg = null;
let lightboxCloseBtn = null;
let lightboxCaption = null;
let lightboxTitle = null;

function initLightbox() {
  if (lightboxOverlay) return;

  // 创建遮罩层
  lightboxOverlay = document.createElement('div');
  lightboxOverlay.className = 'custom-lightbox';
  lightboxOverlay.innerHTML =
    '<div class="lightbox-container">' +
      '<div class="lightbox-header">' +
        '<span class="lightbox-title"></span>' +
        '<button type="button" class="lightbox-close" aria-label="关闭">&times;</button>' +
      '</div>' +
      '<div class="lightbox-body">' +
        '<img class="lightbox-img" src="" alt="">' +
        '<div class="lightbox-caption"></div>' +
      '</div>' +
    '</div>';

  document.body.appendChild(lightboxOverlay);

  lightboxImg = lightboxOverlay.querySelector('.lightbox-img');
  lightboxTitle = lightboxOverlay.querySelector('.lightbox-title');
  lightboxCaption = lightboxOverlay.querySelector('.lightbox-caption');
  lightboxCloseBtn = lightboxOverlay.querySelector('.lightbox-close');

  // 关闭事件 - 点击背景关闭
  lightboxOverlay.addEventListener('click', function(e) {
    if (e.target === lightboxOverlay) {
      closeLightbox();
    }
  });

  lightboxCloseBtn.addEventListener('click', closeLightbox);

  // ESC 关闭
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' && lightboxOverlay.classList.contains('show')) {
      closeLightbox();
    }
  });
}

function openLightbox(src, title, caption) {
  initLightbox();

  title = title || '';
  caption = caption || '';

  lightboxImg.src = src;
  lightboxImg.alt = title;
  lightboxTitle.textContent = title;

  if (caption) {
    lightboxCaption.textContent = caption;
    lightboxCaption.style.display = 'block';
  } else {
    lightboxCaption.style.display = 'none';
  }

  lightboxOverlay.classList.add('show');
  document.body.style.overflow = 'hidden';
}

function closeLightbox() {
  if (!lightboxOverlay) return;
  lightboxOverlay.classList.remove('show');
  lightboxImg.src = '';
  document.body.style.overflow = '';
}

// 全局点击事件委托
document.addEventListener('click', function(e) {
  var link = e.target.closest('a.product-thumb, a[data-bs-toggle="lightbox"]');
  if (link) {
    e.preventDefault();
    e.stopPropagation();
    var href = link.getAttribute('href');
    var title = link.dataset.bsTitle || link.dataset.title || '';
    var innerImg = link.querySelector('img');
    if (!title && innerImg) title = innerImg.alt || '';
    if (href) {
      openLightbox(href, title);
    }
    return;
  }

  var galleryImg = e.target.closest('.gallery-item img, .product-thumb-img');
  if (galleryImg && galleryImg.dataset.full) {
    e.preventDefault();
    e.stopPropagation();
    openLightbox(galleryImg.dataset.full, galleryImg.alt || '');
  }
});

// ===== 多图上传辅助 =====
window.addProductImageField = function(containerSelector) {
  var container = document.querySelector(containerSelector);
  if (!container) return;
  var template = container.querySelector('[data-new-image-row]');
  if (!template) return;
  var row = template.content.cloneNode(true);
  var idx = Date.now() + Math.floor(Math.random() * 1000);
  row.querySelectorAll('input, select').forEach(function(el) {
    if (el.name) el.name = el.name.replace(/NEW_RECORD/g, idx);
    if (el.id) el.id = el.id.replace(/NEW_RECORD/g, idx);
  });
  container.appendChild(row);
  bindImagePreview(container.lastElementChild);
};

function bindImagePreview(row) {
  if (!row || row.dataset.previewBound) return;
  row.dataset.previewBound = 'true';
  var fileInput = row.querySelector('input[type="file"][data-preview-target]');
  if (!fileInput) return;
  var previewWrap = row.querySelector('[data-preview-wrap]');
  var preview = previewWrap ? previewWrap.querySelector('[data-preview]') : row.querySelector('[data-preview]');
  var placeholder = row.querySelector('[data-preview-placeholder]');

  fileInput.addEventListener('change', function(e) {
    var f = e.target.files && e.target.files[0];
    if (!f) {
      if (previewWrap) previewWrap.classList.add('d-none');
      if (placeholder) placeholder.classList.remove('d-none');
      return;
    }
    var reader = new FileReader();
    reader.onload = function(ev) {
      if (preview) {
        preview.src = ev.target.result;
        if (previewWrap) previewWrap.classList.remove('d-none');
      }
      if (placeholder) placeholder.classList.add('d-none');
    };
    reader.readAsDataURL(f);
  });
}

// 绑定所有已存在的上传行
function bindAllImagePreviews() {
  document.querySelectorAll('[data-image-upload-row]').forEach(bindImagePreview);
}

// 页面加载时绑定
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', bindAllImagePreviews);
} else {
  bindAllImagePreviews();
}
document.addEventListener('turbo:load', bindAllImagePreviews);
