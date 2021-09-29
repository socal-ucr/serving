""" TensorFlow Http Archive

Modified http_archive that allows us to override the TensorFlow commit that is
downloaded by setting an environment variable. This override is to be used for
testing purposes.

Add the following to your Bazel build command in order to override the
TensorFlow revision.

build: --action_env TF_REVISION="<git commit hash>"

  * `TF_REVISION`: tensorflow revision override (git commit hash)
"""

_TF_REVISION = "TF_REVISION"

def _tensorflow_http_archive(ctx):
    git_commit = ctx.attr.git_commit
    sha256 = ctx.attr.sha256
    patch = getattr(ctx.attr, "patch", None)

    override_git_commit = ctx.os.environ.get(_TF_REVISION)
    if override_git_commit:
        sha256 = ""
        git_commit = override_git_commit

    strip_prefix = "socal-ucr-tensorflow-upstream-d8d9389"
    urls = [
        "https://github.com/socal-ucr/tensorflow-upstream/tarball/r2.6-rocm-enhanced"
    ]
    ctx.download_and_extract(
        urls,
        "",
        sha256,
        "tar.gz",
        strip_prefix,
    )
    if patch:
        ctx.patch(patch, strip = 1)

tensorflow_http_archive = repository_rule(
    implementation = _tensorflow_http_archive,
    attrs = {
        "git_commit": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = True),
        "patch": attr.label(),
    },
)
