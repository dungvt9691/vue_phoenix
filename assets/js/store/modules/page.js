const state = {
  editing: false,
};

const getters = {
  editing(state) {
    return state.editing;
  },
};

const actions = {
  updateEditing({ commit }, status) {
    commit('UPDATE_EDITING', status);
  },
};

const mutations = {
  UPDATE_EDITING(state, status) {
    state.editing = status;
  },
};

export default {
  state,
  actions,
  mutations,
  getters,
};
