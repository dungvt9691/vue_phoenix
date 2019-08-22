const state = {
  imagePreview: false,
  previewData: {
    imageId: '',
    postId: '',
    type: '',
  },
};

const getters = {
  imagePreview(state) {
    return state.imagePreview;
  },
  previewData(state) {
    return state.previewData;
  },
};

const actions = {
  updateImagePreview({ commit }, status) {
    commit('UPDATE_IMAGE_PREVIEW', status);
  },

  updatePreviewData({ commit }, data) {
    commit('UPDATE_PREVIEW_DATA', data);
  },
};

const mutations = {
  UPDATE_IMAGE_PREVIEW(state, status) {
    state.imagePreview = status;
  },
  UPDATE_PREVIEW_DATA(state, data) {
    state.previewData = data;
  },
};

export default {
  state,
  actions,
  mutations,
  getters,
};
