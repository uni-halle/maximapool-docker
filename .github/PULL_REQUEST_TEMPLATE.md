**Describe your changes and to whom it might be helpful**

If the change addresses an existing issue, mention it (#issuenumber).

**Checklist**
- [ ] [Applied best practice writing docker files](https://developers.redhat.com/blog/2016/02/24/10-things-to-avoid-in-docker-containers/)
- [ ] README.md updated or doen't require changes
- [ ] `assets/maximalocal.mac.template` and `assets/optimize.mac` still match the STACK-version
  _Usually the LMS (ILIAS/ Moodle) plugins create a file in which they store their settings for STACK-Maxima, for example [defining a default size for plots](https://github.com/uni-halle/maximapool-docker/blob/develop/assets/maximalocal.mac.template#L21) or defining which modules to load._
  _In ILIAS the file is located under `/data_dir/xqcas/stack/maximalocal.mac`, in Moodle `$MOODLEDATA/stack/**/maximalocal.mac`._
  _This settings file is then loaded into any non-optimized STACK-Maxima. If optimization is performed, the settings file has to be pre-generated and is baked into the optimized STACK-Maxima._
- [ ] No code smells introduced (e.g. used ShellCheck for Shell scripts)
