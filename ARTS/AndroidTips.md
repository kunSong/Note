### PreferenceFragment & PreferenceGroup
+ PreferenceFragment.findPreference(key)
    >shows a hierarchy of Preference objects as lists. These preferences will automatically save to android.content.SharedPreferences as the user interacts with them. To retrieve an instance of android.content.SharedPreferences that the preference hierarchy in this fragment will use, call PreferenceManager#getDefaultSharedPreferences(android.content.Context) with a context in the same package as this fragment.
+ PreferenceFragment.getPreferences().findPreference(key)
