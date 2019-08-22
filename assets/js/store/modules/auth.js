const state = {
  authenticated: false,
};

const getters = {
  authenticated(state) {
    return state.authenticated;
  },
};

const actions = {
  updateAuthStatus({ commit }, status) {
    commit('UPDATE_AUTH_STATUS', status);
  },
};

const mutations = {
  UPDATE_AUTH_STATUS(state, status) {
    state.authenticated = status;
  },
};

export default {
  state,
  actions,
  mutations,
  getters,
};
