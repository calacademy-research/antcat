import Vue from 'vue'
import Vuex from 'vuex'

import EventBus from "@services/EventBus"

Vue.use(Vuex)

const types = {
  TOGGLE_PANEL: 'TOGGLE_PANEL',
  SET_PANEL_IS_OPEN: 'SET_PANEL_IS_OPEN',
  SET_PANEL_IS_CLOSED: 'SET_PANEL_IS_CLOSED',

  SET_PICKER_REQUESTER_UID: 'SET_PICKER_REQUESTER_UID',
  SET_PICKER_TYPES: 'SET_PICKER_TYPES',
  SET_PICKER_RANKS: 'SET_PICKER_RANKS',
}

export default new Vuex.Store({
  state: {
    isPanelOpen: false,

    pickerRequesterUid: 'no pickerRequesterUid',
    pickerTypes: 'no pickerTypes',
    pickerRanks: 'no pickerRanks',
  },
  getters: {
    isPanelOpen: (state) => state.isPanelOpen,
  },
  actions: {
    openPanel({ commit }) {
      commit(types.SET_PANEL_IS_OPEN)
    },
    setPanelIsOpen({ commit }) {
      commit(types.SET_PANEL_IS_OPEN)
    },
    closePanel({ commit }) {
      commit(types.SET_PANEL_IS_CLOSED)
    },
    togglePanel({ commit }) {
      commit(types.TOGGLE_PANEL)
    },
    requestRecord({ commit, dispatch }, { recordAskerUid, pickableType, pickableRanks }) {
      dispatch('openPanel')

      commit(types.SET_PICKER_REQUESTER_UID, recordAskerUid)
      commit(types.SET_PICKER_TYPES, pickableType)
      commit(types.SET_PICKER_RANKS, pickableRanks)
    },
    replyWithRecord({ dispatch }, {
      recordAskerUid, pickableType, pickedItemId, pickedItem,
    }) {
      EventBus.$emit(`reply-with-record-for-${recordAskerUid}`, pickableType, pickedItemId, pickedItem)
      dispatch('closePanel')
    },
    resetRequestRecord({ commit }) {
      commit(types.SET_PICKER_REQUESTER_UID, null)
      commit(types.SET_PICKER_TYPES, null)
      commit(types.SET_PICKER_RANKS, null)
    },
    notifySuccess({ _context }, content) {
      AntCat.notifySuccess(content) // eslint-disable-line no-undef
    },
    notifyError({ _context }, content) {
      AntCat.notifyError(content) // eslint-disable-line no-undef
    },
  },
  mutations: {
    [types.TOGGLE_PANEL] (state) {
      state.isPanelOpen = !state.isPanelOpen
    },
    [types.SET_PANEL_IS_OPEN] (state) {
      state.isPanelOpen = true
    },
    [types.SET_PANEL_IS_CLOSED] (state) {
      state.isPanelOpen = false
    },
    [types.SET_PICKER_REQUESTER_UID] (state, requesterUid) {
      state.pickerRequesterUid = requesterUid
    },
    [types.SET_PICKER_TYPES] (state, pickerTypes) {
      state.pickerTypes = pickerTypes
    },
    [types.SET_PICKER_RANKS] (state, ranks) {
      state.pickerRanks = ranks
    },
  },
})
