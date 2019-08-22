const state = {
  uploadedImages: [],
  totalImages: 0,
};

const getters = {
  uploadedImages(state) {
    return state.uploadedImages;
  },
  totalImages(state) {
    return state.totalImages;
  },
};

const actions = {
  updateUploadedImages({ commit }, data) {
    commit('UPDATE_UPLOADED_IMAGES', data);
  },
  updateTotalImages({ commit }, count) {
    commit('UPDATE_TOTAL_IMAGES', count);
  },
};

const mutations = {
  UPDATE_UPLOADED_IMAGES(state, data) {
    state.uploadedImages = data;
  },
  UPDATE_TOTAL_IMAGES(state, count) {
    state.totalImages = count;
  },
};

export default {
  state,
  actions,
  mutations,
  getters,
};
