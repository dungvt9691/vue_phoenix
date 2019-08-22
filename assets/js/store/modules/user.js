const state = {
  profile: {},
};

const getters = {
  profile(state) {
    return state.profile;
  },
};

const actions = {
  updateProfileData({ commit }, profile) {
    commit('UPDATE_PROFILE_DATA', profile);
  },
};

const mutations = {
  UPDATE_PROFILE_DATA(state, profile) {
    state.profile = profile;
  },
};

export default {
  state,
  actions,
  mutations,
  getters,
};
